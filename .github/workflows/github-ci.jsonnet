local services = [
  { name: "docker-25", dependsOn: [ "docker--25" ] },
  { name: "minio-release_2024-02-24t17-11-14z", dependsOn: [ "minio__minio--release_2024-02-24t17-11-14z" ] },
  { name: "postgres-12-alpine", dependsOn: [ "postgres--12-alpine" ] },
  { name: "builder-jammy-base-0.4.278", dependsOn: [ "paketobuildpacks__builder-jammy-base--0.4.278" ] },
  { name: "run-jammy-base-0.1.105", dependsOn: [ "paketobuildpacks__run-jammy-base--0.1.105" ] },
  { name: "keycloak-23.0", dependsOn: [ "keycloak__keycloak--23.0" ] },
];

local dependencies = std.set(std.flattenArrays([
    local depList(service) = service.dependsOn;
    depList(service)
    for service in services
]));

local filterArray = {
        [dependency]:  [
            './init/' + dependency + '/**'
        ] for dependency in dependencies
    } + {
        [service.name]:  [
            '' + service.name + '/**'
        ] for service in services
    };

local filters = std.manifestYamlDoc(filterArray, false);

# Пока берется толкьо 0 элемент
local arrayToString(arr) =
  local aux(arr, index) =
    // Assuming escapeStringJson is how you want to serialize
    // the elements. Of course you can use any other way
    // to serialize them (e.g. toString or manifestJson).
    local elem = std.escapeStringJson(arr[index]);
    if index == std.length(arr) - 1 then
        std.format(" || 'needs.changes.outputs.%s' == 'true'", [std.strReplace(elem, "\"", "")])
    else
        elem + std.format(" || 'needs.changes.outputs.%s' == 'true'", [std.strReplace(aux(arr, index + 1))])
  ;
  aux(arr, 0);

local arrayToString2(arr) =
  local aux(arr, index) =
    local elem = std.escapeStringJson(arr[index]);
    if index == std.length(arr) - 1 then
        std.format(" github.event.inputs.build == '%s' ", [std.strReplace(elem, "\"", "")])
    else
        std.format(" github.event.inputs.build == '%s' ", [std.strReplace(elem, "\"", "")])
  ;
  aux(arr, 0);


local gitlabci = {
  # Шаблоны
  name: "Create and publish a Docker image",
  on: {
    workflow_dispatch: {
        inputs: {
            build: {
                type: "choice",
                description: "Who to build",
                options: [
                   service.name for service in services
                ] +  [

                    dependency for dependency in dependencies
                ],
            },
        },
    },
    pull_request: {
        types: [ "closed" ],
    },
    #workflow_run: {
    #    workflows: [ "Create all jobs" ],
    #    types: [ "completed" ]
    #},
    push: {
        "paths-ignore": [ '.github/**' ]
    }
  },
  env: {
        DOCKER_REPO_PASSWORD: "${{ secrets.DOCKER_REPO_PASSWORD }}",
        DOCKER_REPO_USERNAME: "${{ secrets.DOCKER_REPO_USERNAME }}",
        DOCKER_REPO_URL_LOGIN: "${{ vars.DOCKER_REPO_URL_LOGIN }}",
        DOCKER_REPO_URL: "${{ vars.DOCKER_REPO_URL }}",
        CI_PROJECT_NAME: "${{ github.event.repository.name }}"
    },
} + {
jobs : {
     changes: {
        "if": "${{ github.event.inputs.build == null}}",
        "runs-on": [ "self-hosted" ],
       # Required permissions
        permissions:{
            "pull-requests": "read"
        },
        outputs: {
             [dependency]: "${{ 'steps.filter.outputs." + dependency + "' }}"
             for dependency in dependencies
        } + {
            [service.name]: "${{ 'steps.filter.outputs." + service.name + "' }}"
            for service in services
        },
        steps: [
            {
                uses: "dorny/paths-filter@v2",
                id: "filter",
                with: {
                    filters: filters,
                },
            },
        ],
     }
    } + {
     [std.strReplace(dependency, ".", "_")]: {
       "runs-on": [ "self-hosted" ],
       needs: "changes",
       "if": std.format("${{ github.event.inputs.build == '%s' || 'needs.changes.outputs.%s' == 'true' && always() }}", [dependency, dependency]),
       env: {
         SERVICE_NAME: dependency,
         IMAGE: "${{ vars.DOCKER_REPO_URL }}${{ github.event.repository.name }}/" + dependency + ":latest"
       },
       steps: [
         { uses: "actions/checkout@v3", },
         { run: "echo $DOCKER_REPO_PASSWORD | docker login $DOCKER_REPO_URL_LOGIN -u $DOCKER_REPO_USERNAME --password-stdin", },
         { run: "echo " +  dependency, },
         { run: "docker build --build-arg DOCKER_REPO_URL --build-arg CI_PROJECT_NAME -t $IMAGE ./init/$SERVICE_NAME", },
         { run: "docker push $IMAGE", },
       ],
     }, for dependency in dependencies
 }  + {
    [std.strReplace(service.name, ".", "_")]: {
      "runs-on": [ "self-hosted" ],
      needs:  [ "changes" ] + std.map(function(x) std.strReplace(x, ".", "_"), service.dependsOn),
      "if": std.format("${{ github.event.inputs.build == '%s' || ('needs.changes.outputs.%s' == 'true'%s) || (%s) && always() }}", [service.name, service.name, arrayToString(service.dependsOn), arrayToString2(service.dependsOn)]),
      env: {
        SERVICE_NAME: service.name,
        IMAGE: "${{ vars.DOCKER_REPO_URL }}${{ github.event.repository.name }}/" + service.name + ":latest"
      },
      steps: [
        { uses: "actions/checkout@v3" },
        { run: "echo $DOCKER_REPO_PASSWORD | docker login $DOCKER_REPO_URL_LOGIN -u $DOCKER_REPO_USERNAME --password-stdin" },
        { run: "echo " +  service.name },
        { run: "docker build --build-arg DOCKER_REPO_URL --build-arg CI_PROJECT_NAME -t $IMAGE ./$SERVICE_NAME" },
        { run: "docker push $IMAGE" },
      ],
    }, for service in services
}
};

std.manifestYamlDoc(gitlabci, true)