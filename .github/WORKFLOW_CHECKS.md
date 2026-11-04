# Offline image-workflow checks

The generator and generated YAML use expression context lookups for filter outputs. Keys containing dots or hyphens are accessed with `outputs['key']`. A quoted string such as `'needs.changes.outputs.docker-25'` never reads the output and therefore disables automatic image selection.

Run from this repository with Python 3 + PyYAML, Node 20+, Jsonnet and the official `@actions/expressions` package available outside the repository:

```sh
JSONNET=/path/to/jsonnet \
ACTIONS_EXPRESSIONS_MODULE=/path/to/actions-expressions/dist/index.js \
python3 .github/scripts/test-workflow.py
```

Validated tools: Go Jsonnet 0.22.0 and `@actions/expressions` 0.3.61. The script does not install tools or execute workflow steps. It checks generated YAML against Jsonnet output (LF repository bytes, allowing Git's CRLF checkout conversion), evaluates actual expressions using GitHub's parser/evaluator, exercises all 14 image changes and all 14 manual choices, and rejects independent regressions in output references and job conditions. The expected automatic fan-out comes from declared dependency edges. It verifies that all filters target exactly the 14 Dockerfile directories and that source-only changes select no image jobs.

`validate-workflow.yml` runs these same checks for source changes in pull requests to `main`, or by an explicit validation dispatch. It uses an Ubuntu hosted runner, read-only contents permission, disabled checkout credential persistence and pinned validation tools. It has no repository secrets, image build/push steps or self-hosted runner.

This is expression and generation validation. It does not emulate the hosted scheduler, job status/skip propagation, runner configuration, credentials, image builds or publication. Manual choices and existing `always()` placement are preserved; manual release execution has not been certified by these checks.

## Source-only integration

Keep the fix PR against `main` limited to `.github/` files. Before publication, review its complete diff and verify that no image directory, Dockerfile, PostgreSQL configuration, registry variable or secret changes. Do not combine this PR with image changes.

A push changing `.github/` files other than generated-config.yml can start `deploy-image.yml`. That workflow calls `sea-ls/pipe` on `main`, which executes Jsonnet and attempts to commit/push generated-config.yml. Offline generation parity prevents an expected content rewrite, but the runner's actual Jsonnet version/configuration and remote workflow execution are not verified here. The generator workflow is automation, not a passive check.

The image workflow ignores `.github/**` on push, including the generator's own generated-file commit. It also runs on **every PR close**, merged or unmerged. For this source-only PR, its changes job may run, but every image-directory filter is false, so all image build/push conditions evaluate false. This depends on the PR remaining source-only and the filters retaining their verified directory scope. Do not manually dispatch an image build as a validation step.

Publishing the source branch/PR and merging remain separate actions. No workflow has been dispatched, no registry login performed and no image built/pushed during local validation.
