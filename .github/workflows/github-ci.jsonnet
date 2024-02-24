local services = [
  { name: "docker-25",                    dependsOn: [ "docker--25" ] },
];

local dependencies = std.set(std.flattenArrays([
    local depList(service) = service.dependsOn;
    depList(service)
    for service in services
]));


local gitlabci = {
  # Шаблоны
  name: "Create and publish a Docker image",
  on: { workflow_dispatch: {}},
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
                    filters: "|" + {
                        [dependency]:  [
                            './init/' + dependency + '/**'
                        ] for dependency in dependencies
                    } + {
                        [service.name]:  [
                            service.name + '/**'
                        ] for service in services
                    }
                },
            },
        ],
     }
    } + {
     [dependency]: {
       "runs-on": [ "self-hosted" ],
       needs: changes,
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
      needs: service.dependsOn,
      env: {
        SERVICE_NAME: service.name,
        IMAGE: "${{ vars.DOCKER_REPO_URL }}${{ github.event.repository.name }}/" + service.name + ":latest"
      },
      steps: [
        { uses: "actions/checkout@v3" },
        { run: "echo $DOCKER_REPO_PASSWORD | docker login $DOCKER_REPO_URL_LOGIN -u $DOCKER_REPO_USERNAME --password-stdin" },
        { run: "echo " +  service.name },
        { run: "docker build --build-arg DOCKER_REPO_URL --build-arg CI_PROJECT_NAME -t $IMAGE ./init/$SERVICE_NAME" },
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