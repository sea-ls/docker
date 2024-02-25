ARG DOCKER_REPO_URL
ARG docker_repo_url=$DOCKER_REPO_URL
ARG CI_PROJECT_NAME
ARG base_project_name=$CI_PROJECT_NAME
FROM ${docker_repo_url}${base_project_name}/docker--25

RUN apk --no-cache add -U jsonnet \
      && apk --no-cache add openjdk21 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
      && apk --no-cache add maven --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
      && apk add --no-cache git \
      && apk add --no-cache bash \
      && apk add --no-cache git-flow