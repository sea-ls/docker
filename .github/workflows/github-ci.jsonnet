local services = [
  { name: "docker-25", dependsOn: [ "docker--25" ] },
  { name: "minio-release_2024-02-24t17-11-14z", dependsOn: [ "minio__minio--release_2024-02-24t17-11-14z" ] },
  { name: "postgres-12-alpine", dependsOn: [ "postgres--12-alpine" ] },
  { name: "builder-jammy-base-0_4_278", dependsOn: [ "paketobuildpacks__builder-jammy-base--0_4_278" ] },
  { name: "run-jammy-base-0_1_105", dependsOn: [ "paketobuildpacks__run-jammy-base--0_1_105" ] },
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
       " || needs.changes.outputs." + std.strReplace(elem, "\"", "") + " == 'true'"
    else
      elem + " || needs.changes.outputs." +  std.strReplace(aux(arr, index + 1)) + " == 'true'"
  ;
  aux(arr, 0);

local arrayToString2(arr) =
  local aux(arr, index) =
    local elem = std.escapeStringJson(arr[index]);
    if index == std.length(arr) - 1 then
        std.format(" github.event.inputs.build == '%s' ", [std.strReplace(elem, "\"", "")])
       //" github.event.inputs.build == '" + std.strReplace(elem, "\"", "") + "'"
    else
      " github.event.inputs.build == '" + std.strReplace(elem, "\"", "") + "'"
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
    workflow_run: {
        workflows: [ "Create all jobs" ],
        types: [ "completed" ]
    },
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
             [dependency]: "${{ steps.filter.outputs." + dependency + " }}"
             for dependency in dependencies
        } + {
            [service.name]: "${{ steps.filter.outputs." + service.name + " }}"
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
     [dependency]: {
       "runs-on": [ "self-hosted" ],
       needs: "changes",
       "if": "${{ github.event.inputs.build == '" + dependency + "' || needs.changes.outputs." + dependency + " == 'true' && always() }}",
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
    [service.name]: {
      "runs-on": [ "self-hosted" ],
      needs:  [ "changes" ] + service.dependsOn,
      "if": "${{ github.event.inputs.build == '" + service.name + "' || (needs.changes.outputs." + service.name + " == 'true'" + arrayToString(service.dependsOn) +  ") || (" + arrayToString2(service.dependsOn) + ") && always() }}",
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