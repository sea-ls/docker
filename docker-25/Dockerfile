ARG DOCKER_REPO_URL
ARG docker_repo_url=$DOCKER_REPO_URL
ARG CI_PROJECT_NAME
ARG base_project_name=$CI_PROJECT_NAME
FROM ${docker_repo_url}${base_project_name}/docker--25

RUN apk --no-cache add -U jsonnet \
      && wget https://github.com/grafana/grafonnet-lib/archive/refs/heads/master.zip \
      && unzip master.zip -d master \
      && mkdir grafonnet-lib \
      && mv -v master/grafonnet-lib-master/* grafonnet-lib/ \
      && rm -rf master \
      && : \
      && apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
      && apk --no-cache add maven --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
      && apk add --no-cache git \
      && apk add --no-cache bash \
      && apk add --no-cache git-flow