local services = [
  { name: "alertmanager",                    dependsOn: [ "bitnami__alertmanager--latest" ] },
  { name: "alertmanager-discord",            dependsOn: [ "golang--1.16-alpine", "alpine--3.13" ] },
  { name: "alertmanager-telegram",           dependsOn: [  ] },
  { name: "alertmanager-notifier",           dependsOn: [  ] },
  { name: "apk-builder" ,                    dependsOn: [ "timbru31__java-node--8-jdk-fermium" ] },
  { name: "apk-native-builder",              dependsOn: [ "openjdk--11-jdk" ] },
  { name: "cadvisor",                        dependsOn: [ "zcube__cadvisor--v0.45.0" ] },
  { name: "consul",                          dependsOn: [ "bitnami__consul--latest" ] },
  { name: "db-backup",                       dependsOn: [ "tiredofit__db-backup--latest", "s3-utils" ] },
  { name: "docker19",                        dependsOn: [ "docker--19" ] },
  { name: "docker20",                        dependsOn: [ "docker--20" ] },
  { name: "python3.7",                       dependsOn: [ "python--3.7-alpine" ] },
  { name: "docker-gen",                      dependsOn: [ "golang--1.16-alpine", "alpine--3.13" ] },
  { name: "elk-elasticsearch-7-10-1",        dependsOn: [ "elasticsearch--7.10.1" ] },
  { name: "elk-elasticsearch-8-4-1",         dependsOn: [ "elasticsearch--8.4.1" ] },
  { name: "elk-kibana-7-10-1",               dependsOn: [ "kibana--7.10.1" ] },
  { name: "elk-kibana-8-4-1",                dependsOn: [ "kibana--8.4.1" ] },
  { name: "elk-logstash-7-10-1",             dependsOn: [ "logstash--7.10.1" ] },
  { name: "elk-logstash-8-4-1",              dependsOn: [ "logstash--8.4.1" ] },
  { name: "front-java-node",                 dependsOn: [ "node--lts-buster" ] },
  { name: "front-nathanfriend-java-node-git",dependsOn: [ "nathanfriend__java-node-git--11-alpine" ] },
  { name: "front-trion-ng-cli",              dependsOn: [ "trion__ng-cli--14.0.2" ] },
  { name: "ftp-server",                      dependsOn: [ "fauria__vsftpd--latest" ] },
  { name: "ftps-server",                     dependsOn: [ "vsftpd-alpine--latest" ] },
  { name: "grafana",                         dependsOn: [ "grafana__grafana--8.0.6" ] },
  { name: "grafana-libs-python",             dependsOn: [ "grafana__grafana--9.3.1" ] },  //Зависит уже от вторичной grafana
  { name: "grafana-libs",                    dependsOn: [ ] },  //Зависит уже от вторичной grafana
  { name: "grafana-loki",                    dependsOn: [ "grafana__loki--2.8.2" ] },
  { name: "grafana-promtail",                dependsOn: [ "grafana__promtail--2.8.2" ] },
  { name: "grafana-agent",                   dependsOn: [ "grafana__agent--v0.34.1" ] },
  { name: "grafana-tempo",                   dependsOn: [ "grafana__tempo--2.1.1" ] },
  { name: "grafana-tempo-query",             dependsOn: [ "grafana__tempo-query--2.1.1" ] },
  { name: "grafana-image-renderer",          dependsOn: [ "grafana__grafana-image-renderer--latest" ] },
  { name: "influxdb-1.8.10",                 dependsOn: [ "influxdb--1.8.10" ] },
  { name: "influxdb-2.5.1",                  dependsOn: [ "influxdb--2.5.1" ] },
  { name: "jmeter",                          dependsOn: [ ] }, //Зависит уже от вторичного docker19
  { name: "maven-jdk",                       dependsOn: [ "maven--3.6.3-jdk-11" ] },
  { name: "minio",                           dependsOn: [ "minio__minio--release.2021-06-17t00-10-46z" ] },
  { name: "minio-console",                   dependsOn: [ "minio__console--latest" ] },
  { name: "mongo4",                          dependsOn: [ "mongo--4" ] },
  { name: "mongo-express",                   dependsOn: [ "mongo-express--latest" ] },
  { name: "network-multitool",               dependsOn: [ "praqma__network-multitool--extra" ] },
  { name: "nexus3",                          dependsOn: [ "sonatype__nexus3--latest" ] },
  { name: "nginx",                           dependsOn: [ "debian--buster-slim" ] },
  //{ name: "nginxplus",                     dependsOn: [ "alpine--3.11" ] } //Платная версия, чтобы её можно было собрать, нужно иметь сертифика",  .
  { name: "node",                            dependsOn: [ "node--14.8.0-slim" ] },
  { name: "node16",                          dependsOn: [ "alpine--3.14" ] },
  { name: "nginx-exporter",                  dependsOn: [ "bitnami__nginx-exporter--latest" ] },
  { name: "nginx-proxy",                     dependsOn: [ "jwilder__nginx-proxy--latest" ] },
  { name: "nginx-vts-exporter",              dependsOn: [ "sophos__nginx-vts-exporter--latest" ] },
  { name: "node-public-frontend",            dependsOn: [ "node--17.0.0-slim" ] },
  { name: "paketo-full",                     dependsOn: [ "paketobuildpacks__builder--0.2.382-full" ] },
  { name: "paketo-run-full",                 dependsOn: [ "paketobuildpacks__run--full-cnb" ] },
  { name: "paketo-run-base",                 dependsOn: [ "paketobuildpacks__run--1.2.60-base-cnb" ] },
  { name: "postgres12-alpine",               dependsOn: [ "postgres--12-alpine", "s3-utils" ] },
  { name: "postgres12-timescale",            dependsOn: [ "timescale__timescaledb--latest-pg12" ] },
  { name: "postgres-exporter",               dependsOn: [ "wrouesnel__postgres_exporter--latest" ] },
  { name: "postgres-multiple-db",            dependsOn: [ ] }, //Зависит уже от вторичного postgres12-alpine
  { name: "prometheus",                      dependsOn: [ "bitnami__prometheus--2.41.0" ] },
  { name: "prometheus-jsonnet-libs",         dependsOn: [ ] }, //Зависит уже от вторичного prometheus
  { name: "push-notification-mongo",         dependsOn: [ "mongo--4.4" ] },
  { name: "pushgateway",                     dependsOn: [ "bitnami__pushgateway--1.4.3" ] },
  { name: "rabbitmq",                        dependsOn: [ "rabbitmq--3-management-alpine" ] },
  { name: "redis6",                          dependsOn: [ "redis--6" ] },
  { name: "s3-utils",                        dependsOn: [ ] },
  { name: "selenium-standalone-chrome",      dependsOn: [ "selenium__standalone-chrome--latest" ] },
  { name: "selenium-standalone-chrome-115.0",dependsOn: [ "selenium__standalone-chrome--115.0" ] },
  { name: "skywalking-oap-server",           dependsOn: [ "apache__skywalking-oap-server--9.3.0" ] },
  { name: "skywalking-ui",                   dependsOn: [ "apache__skywalking-ui--9.3.0" ] },
  { name: "thin",                            dependsOn: [ "openjdk--11-jdk-slim", "openjdk--11-jre-slim" ] },
  { name: "timberio-vector",                 dependsOn: [ "timberio__vector--0.27.0-alpine" ] },
  { name: "ubuntu-onlyoffice-libs",          dependsOn: [ "ubuntu__18.04" ] },
  { name: "ubuntu-onlyoffice-build",         dependsOn: [ "ubuntu-onlyoffice-libs" ] },
  { name: "ubuntu-onlyoffice-env",           dependsOn: [ "ubuntu-onlyoffice-libs" ] },
  { name: "ubuntu-onlyoffice-postgres",      dependsOn: [ "postgres12-alpine" ] },
  { name: "ubuntu-test",                     dependsOn: [ "ubuntu__18.04" ] },
  { name: "zipkin",                          dependsOn: [ "openzipkin__zipkin--latest" ] },
  { name: "kafka",                           dependsOn: ["kafka--3.2.3"]},
  { name: "zookeeper",                       dependsOn: ["zookeeper--latest"]},
  { name: "solr",                            dependsOn: ["solr--latest"]},
];

local dependencies = std.set(std.flattenArrays([
    local depList(service) = service.dependsOn;
    depList(service)
    for service in services
]));

local include_file(project, file) = {
  project: project,
  file: file,
};

/////////////////////////////////////////////////////
/////           BACKUP IMAGES REMOTE           /////
///////////////////////////////////////////////////

///// COMMON BACKUP IMAGES REMOTE /////

local pull_tag_and_push_backup(var_container_name, var_docker_branch_name, var_backup_tag) = [
  'LAST_BACKUP_TAG_PART=_LAST_BACKUP',
  'PULL_IMAGE_NAME=${DOCKER_REGISTRY_URL}/${CI_PROJECT_NAME}/' + var_container_name + ':' + var_docker_branch_name,
  'PUSH_IMAGE_NAME=${TARGET_DOCKER_REPO_URL}/${CI_PROJECT_NAME}/' + var_container_name + ':' + var_docker_branch_name + var_backup_tag,
  'PUSH_IMAGE_LAST_BACKUP_NAME=${TARGET_DOCKER_REPO_URL}/${CI_PROJECT_NAME}/' + var_container_name + ':' + var_docker_branch_name + '$LAST_BACKUP_TAG_PART',
  'echo $PULL_IMAGE_NAME',
  'echo $PUSH_IMAGE_NAME',
  'echo $PUSH_IMAGE_LAST_BACKUP_NAME',
  'docker pull ${PULL_IMAGE_NAME}',
  'docker tag ${PULL_IMAGE_NAME} ${PUSH_IMAGE_NAME}',
  'docker tag ${PULL_IMAGE_NAME} ${PUSH_IMAGE_LAST_BACKUP_NAME}',
  'docker push ${PUSH_IMAGE_NAME}',
  'docker push ${PUSH_IMAGE_LAST_BACKUP_NAME}',
  'docker rmi ${PULL_IMAGE_NAME}',
  'docker rmi ${PUSH_IMAGE_NAME}',
  'docker rmi ${PUSH_IMAGE_LAST_BACKUP_NAME}',
];

local job_base_separate_back_up(scope, imageName) = {
  stage: 'bkp-' + scope + '-remote',
  cache: { },
  script:
  [ 'export NEW_TAG=_backup_$(date +%Y_%m_%d)' ] +
  pull_tag_and_push_backup(imageName, 'latest', '$NEW_TAG') +
  [
    'echo ' + imageName + ' backup finish',
  ],
  rules: [
        {
        allow_failure: true,
        when: "manual"
        },
  ],
  tags: ['ucso-deploy-manager'],
};

local separate_back_up_remote_image(scope, imageName) =
job_base_separate_back_up(scope, imageName) +
{
  before_script: [
    'echo -n $GITLAB_CI_PASSWORD | docker login -u $GITLAB_CI_USERNAME --password-stdin $DOCKER_REPO_URL$CI_PROJECT_NAME',
    'DOCKER_REGISTRY_URL=$UCSO_REMOTE_REGISTRY',
    'TARGET_DOCKER_REPO_URL=$UCSO_REMOTE_REGISTRY'
  ]
};

///// BACKUP IMAGES REMOTE /////

local separate_back_up_images() = if ( std.extVar('need_bkp') == 'true' ) then {
  ['bkp-image-remote-' + service.name]:
      separate_back_up_remote_image('images', service.name)
    for service in services
} else { };

///// BACKUP DEPENDENCIES REMOTE /////

local separate_back_up_dependencies() = if ( std.extVar('need_bkp') == 'true' ) then {
  ['bkp-dependency-remote-' + dependency]:
      separate_back_up_remote_image('dependencies', dependency)
    for dependency in dependencies
} else { };

////////////////////////////////////////////////////

local pull_tag_and_push_ubuntu_test() = {
  'tag-ubuntu-test': {
      stage: 'ubuntu-test-image-for-develop',
      cache: { },
      script:
      [
        'docker pull gitlab-registry.opencode.su/ucso/ucso-docker/ubuntu-test:latest',
        'docker tag gitlab-registry.opencode.su/ucso/ucso-docker/ubuntu-test:latest gitlab-registry.opencode.su/ucso/ucso-backend/ubuntu-test:develop',
        'docker push gitlab-registry.opencode.su/ucso/ucso-backend/ubuntu-test:develop',
      ],
      rules: [
        {
          allow_failure: true,
          when: "manual"
        },
      ],
      tags: ['ucso-deploy-manager'],
  }
};

local gitlabci = {
  variables: {
    DOCKER_DRIVER: "overlay2",
  },

  include: [
    //include_file('ucso/Pipe', 'Deployment.gitlab-ci.yml'),
    include_file('ucso/Pipe', 'Commons.gitlab-ci.yml'),
  ],

  stages: [
    "remove-old-images",
    "bkp-dependencies-remote",
    "build-dependencies",
    "bkp-images-remote",
    "build-images",
    "ubuntu-test-image-for-develop",
    "deploy",
  ],

  # Шаблоны
  ".images-names": {
    variables: {
      IMAGE: "${DOCKER_REPO_URL}${CI_PROJECT_NAME}/${SERVICE_NAME}:latest",
      RESTORE_IMAGE_TAG: 'latest_LAST_BACKUP'
    },
  },
} + {
     [dependency]: {
       extends: ".images-names",
       stage: "build-dependencies",
       image: "docker:20",
       variables: {
         SERVICE_NAME: dependency
       },
       script: [
         "echo -n $GITLAB_CI_PASSWORD | docker login -u $GITLAB_CI_USERNAME --password-stdin $DOCKER_REPO_URL$CI_PROJECT_NAME",
         "pwd",
         "docker build --build-arg DOCKER_REPO_URL --build-arg CI_PROJECT_NAME --build-arg MVN_REPO -t $IMAGE ./init/" + dependency,
         "docker push $IMAGE",
       ],
       rules: [
         {
           changes: [
             "init/" + dependency + "/**",
           ],
         },
         {
           allow_failure: true,
           when: "manual",
         },
       ],
 //      environment: {
 //        name: "dev",
 //        url: "https://ucso-dev.opencode.su",
 //      },
     }, for dependency in dependencies
 }  + {
    [service.name]: {
      extends: ".images-names",
      stage: "build-images",
      image: "${DOCKER_REPO_URL}${CI_PROJECT_NAME}/docker--19",
      variables: {
        SERVICE_NAME: service.name
      },
      script: [
        "echo -n $GITLAB_CI_PASSWORD | docker login -u $GITLAB_CI_USERNAME --password-stdin $DOCKER_REPO_URL$CI_PROJECT_NAME",
        "pwd",
        "docker build --build-arg DOCKER_REPO_URL --build-arg CI_PROJECT_NAME --build-arg MVN_REPO -t $IMAGE ./" + service.name,
        "docker push $IMAGE",
      ],
      rules: [
        {
          changes: [
            service.name + "/**",
            //Можно было бы автоматически пересобирать при изменениях в зависимостях,
            //но лучше вручную, чтобы по ошибке не запустить пересборку рабочих образов
          ],
        },
        {
          allow_failure: true,
          when: "manual",
        },
      ],
//      environment: {
//        name: "dev",
//        url: "https://ucso-dev.opencode.su",
//      },
    }, for service in services
} + {
    //Для успешного завершения pipeline на случай, если изменения произошли в корне
    "empty-job": {
      stage: "deploy",
      script: [
        "echo No deploy assumed",
      ],
}
}
+ pull_tag_and_push_ubuntu_test()
+ separate_back_up_images()
+ separate_back_up_dependencies();

std.manifestYamlDoc(gitlabci, true)

