ARG DOCKER_REPO_URL
ARG docker_repo_url=$DOCKER_REPO_URL
ARG CI_PROJECT_NAME
ARG base_project_name=$CI_PROJECT_NAME
FROM ${docker_repo_url}${base_project_name}/postgres--12-alpine

COPY postgresql.conf /var/lib/postgresql/data/pgdata/postgresql.conf
COPY pg_hba.conf /var/lib/postgresql/data/pgdata/pg_hba.conf