ARG DOCKER_REPO_URL
ARG docker_repo_url=$DOCKER_REPO_URL
ARG CI_PROJECT_NAME
ARG base_project_name=$CI_PROJECT_NAME
FROM ${docker_repo_url}${base_project_name}/keycloak__keycloak--23.0

COPY ../entrypoint_overwrited.sh /entrypoint_overwrited.sh