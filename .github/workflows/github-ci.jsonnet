local services = [
  //{ name: "docker-25", dependsOn: [ "docker--25" ] },
  { name: "minio-release_2024-02-24t17-11-14z", dependsOn: [ "minio__minio--release_2024-02-24t17-11-14z" ] },
  { name: "postgres-16", dependsOn: [ "postgres--16" ] },
];

local dependencies = std.set(std.flattenArrays([
    local depList(service) = service.dependsOn;
    depList(service)
    for service in services
]));

local testA = {
        [dependency]:  [
            './init/' + dependency + '/**'
        ] for dependency in dependencies
    } + {
        [service.name]:  [
            '' + service.name + '/**'
        ] for service in services
    };

local str_templating = std.manifestYamlDoc(testA, false);

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
        }
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
        "runs-on": [ "self-hosted" ],
        # Required permissions
        permissions:{
            "pull-requests": "read"
        } ,
        outputs: {
             [dependency]: "${{ steps.filter.outputs." + dependency + " }}"
             for dependency in dependencies
        } + {
            [service.name]: "${{ steps.filter.outputs." + service.name + " }}"
            for service in services
        },
        steps: [
            {
                uses: "dorny/paths-filter@v3",
                id: "filter",
                with: {
                    filters: str_templating,
                },
            },
        ],
     }
    } + {
     [dependency]: {
       "runs-on": [ "self-hosted" ],
       needs: "changes",
       "if": "${{github.event.inputs.build == '" + dependency + "' || needs.changes.outputs." + dependency + " == 'true' && always() }}",
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
 //      environment: {
 //        name: "dev",
 //        url: "https://ucso-dev.opencode.su",
 //      },
     }, for dependency in dependencies
 }  + {
    [service.name]: {
      "runs-on": [ "self-hosted" ],
      needs:  [ "changes" ] + service.dependsOn,
      "if": "${{github.event.inputs.build == '" + service.name + "' || (needs.changes.outputs." + service.name + " == 'true'" + arrayToString(service.dependsOn) + ") && always() }}",
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
//     environment: {
//       name: "dev",
//       url: "https://ucso-dev.opencode.su",
//     },
    }, for service in services
}
};

std.manifestYamlDoc(gitlabci, true)