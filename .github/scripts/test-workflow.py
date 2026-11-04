#!/usr/bin/env python3
"""Offline policy regression. Requires Python PyYAML, Node and a Jsonnet executable.
No workflow, Docker command, git mutation, remote request or registry access is executed.
"""
import copy
import json
import os
from pathlib import Path
import re
import subprocess
import unittest
import yaml

ROOT = Path(__file__).resolve().parents[2]
GENERATOR = ROOT / '.github/workflows/github-ci.jsonnet'
GENERATED = ROOT / '.github/workflows/generated-config.yml'
JSONNET = os.environ.get('JSONNET', 'jsonnet')
NODE = os.environ.get('NODE', 'node')


def load(text):
    # BaseLoader preserves the GitHub Actions key `on` (YAML 1.1 treats it as bool).
    return yaml.load(text, Loader=yaml.BaseLoader)


def evaluate(expressions, context):
    # Use GitHub's official parser/evaluator, not a replacement expression grammar.
    # always() is explicitly modelled true; hosted dependency scheduling is separate.
    program = """
import {readFileSync} from 'node:fs';
const {Parser, Lexer, Evaluator, data} = await import(process.env.ACTIONS_EXPRESSIONS_MODULE);
const {expressions, context} = JSON.parse(readFileSync(0, 'utf8'));
const functions = [{name: 'always', minArgs: 0, maxArgs: 0, call: () => new data.BooleanData(true)}];
const contextData = JSON.parse(JSON.stringify(context), data.reviver);
const result = expressions.map(x => {
 const expression = x.slice(3, -2).trim();
 const tokens = new Lexer(expression).lex().tokens;
 const ast = new Parser(tokens, Object.keys(context), functions).parse();
 return new Evaluator(ast, contextData, new Map(functions.map(f => [f.name, f]))).evaluate();
});
process.stdout.write(JSON.stringify(result, data.replacer));
"""
    if not os.environ.get('ACTIONS_EXPRESSIONS_MODULE'):
        raise RuntimeError('Set ACTIONS_EXPRESSIONS_MODULE to official @actions/expressions dist/index.js')
    return json.loads(subprocess.check_output(
        [NODE, '--input-type=module', '-e', program],
        input=json.dumps({'expressions': expressions, 'context': context}).encode()))



def selected(workflow, changed=(), build=None):
    jobs = workflow['jobs']
    outputs = jobs['changes']['outputs']
    context = {'github': {'event': {'inputs': {'build': build}}},
               'steps': {'filter': {'outputs': {key: 'true' if key in changed else 'false' for key in outputs}}}}
    values = evaluate(list(outputs.values()), context)
    context['needs'] = {'changes': {'outputs': dict(zip(outputs, values))}}
    image_jobs = {key: value for key, value in jobs.items() if key != 'changes'}
    enabled = evaluate([value['if'] for value in image_jobs.values()], context)
    return {value['env']['SERVICE_NAME'] for value, enabled in zip(image_jobs.values(), enabled) if enabled}


class WorkflowRegression(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.workflow = load(GENERATED.read_text())
        cls.filters = load(cls.workflow['jobs']['changes']['steps'][1]['with']['filters'])
        cls.images = {p.parent.relative_to(ROOT).as_posix(): p.parent.name for p in ROOT.glob('**/Dockerfile')}

    def test_generation_parity(self):
        generated = subprocess.check_output([JSONNET, '-S', str(GENERATOR)])
        # Git may materialize CRLF under core.autocrlf; compare repository LF bytes.
        self.assertEqual(GENERATED.read_bytes().replace(b'\r\n', b'\n'), generated)

    def test_filters_cover_only_exact_image_directories(self):
        self.assertEqual(set(self.filters), set(self.images.values()))
        for directory, name in self.images.items():
            self.assertEqual([s.removeprefix('./') for s in self.filters[name]], [directory + '/**'])
        self.assertEqual(len(self.images), 14)

    def test_changed_image_selection_and_source_only_no_publish(self):
        jobs = self.workflow['jobs']
        self.assertEqual(selected(self.workflow), set())
        # Expected fan-out comes from declared job dependency edges, not expressions.
        for directory, name in self.images.items():
            job_id = next(k for k, v in jobs.items() if v.get('env', {}).get('SERVICE_NAME') == name)
            expected = {name}
            for job in jobs.values():
                needs = job.get('needs', [])
                if isinstance(needs, str):
                    needs = [needs]
                if job_id in needs:
                    expected.add(job['env']['SERVICE_NAME'])
            with self.subTest(changed=name):
                self.assertEqual(selected(self.workflow, [name]), expected)

    def test_manual_choices_preserved(self):
        choices = self.workflow['on']['workflow_dispatch']['inputs']['build']['options']
        self.assertEqual(set(choices), set(self.images.values()))
        for name in choices:
            self.assertIn(name, selected(self.workflow, build=name))

    def test_source_integration_trigger_boundaries(self):
        events = self.workflow['on']
        self.assertEqual(events['push']['paths-ignore'], ['.github/**'])
        self.assertEqual(events['pull_request']['types'], ['closed'])
        deploy = load((ROOT / '.github/workflows/deploy-image.yml').read_text())
        self.assertEqual(deploy['on']['push']['paths'], ['.github/**', '!.github/workflows/generated-config.yml'])
        self.assertEqual(deploy['jobs']['call-workflow']['uses'],
                         'sea-ls/pipe/.github/workflows/pipeline-generation.github-ci.yml@main')
        validation = load((ROOT / '.github/workflows/validate-workflow.yml').read_text())
        self.assertEqual(validation['permissions'], {'contents': 'read'})
        self.assertEqual(set(validation['on']), {'pull_request', 'workflow_dispatch'})
        self.assertEqual(validation['jobs']['validate']['runs-on'], 'ubuntu-latest')
        self.assertEqual(validation['jobs']['validate']['steps'][0]['with']['persist-credentials'], 'false')
        self.assertNotIn('secrets.', json.dumps(validation))
        # A PR that changes only .github files has no image-directory filter match.
        changed = [p for p in ['.github/workflows/github-ci.jsonnet',
                              '.github/workflows/generated-config.yml',
                              '.github/scripts/test-workflow.py']
                   if any(p.startswith(d + '/') for d in self.images)]
        self.assertEqual(changed, [])
        self.assertEqual(selected(self.workflow, changed), set())

    def test_negative_control_literal_output(self):
        broken = copy.deepcopy(self.workflow)
        broken['jobs']['changes']['outputs']['docker-25'] = "${{ 'steps.filter.outputs.docker-25' }}"
        self.assertNotEqual(selected(broken, ['docker-25']), {'docker-25'})

    def test_negative_control_literal_condition(self):
        broken = copy.deepcopy(self.workflow)
        broken['jobs']['docker-25']['if'] = re.sub(
            r"needs\.changes\.outputs\['([^']+)'\]", r"'needs.changes.outputs.\1'",
            broken['jobs']['docker-25']['if'])
        self.assertNotEqual(selected(broken, ['docker-25']), {'docker-25'})


if __name__ == '__main__':
    unittest.main(verbosity=2)
