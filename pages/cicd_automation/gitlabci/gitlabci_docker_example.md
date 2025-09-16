---
layout: page
title: GitlabCi - Docker Example
parent: GitlabCi
permalink: /cicd_automation/gitlabci/gitlabci_docker_example
nav_order: 1
---

# 🛠️ CI/CD GitLab For Docker Build

---



## 1) `.gitlab-ci.yml` — Lint, Build, Scan Image, Push ECR

```yaml

```
include:
  - local: ".gitlabci/common/*.yml"

# =========================
# Variables globales Docker
# =========================
variables:
  BASE_PATH: "$CI_PROJECT_DIR"
  DOCKER_IMAGE: "$CI_REGISTRY_IMAGE"
  DOCKER_TAG: "$CI_COMMIT_REF_SLUG"
  DOCKER_LATEST_TAG: "latest"
  DOCKERFILE_PATH: "Dockerfile"
  DOCKER_BUILD_CONTEXT: "."

  # Activer buildkit
  DOCKER_BUILDKIT: "1"

# =========================
# Anchors réutilisables
# =========================
.docker-login: &docker-login
  - echo "$CI_REGISTRY_PASSWORD" | docker login -u "$CI_REGISTRY_USER" --password-stdin "$CI_REGISTRY"

.docker-build: &docker-build
  - docker build --pull -f "$DOCKERFILE_PATH" -t "$DOCKER_IMAGE:$DOCKER_TAG" "$DOCKER_BUILD_CONTEXT"

.docker-push: &docker-push
  - docker push "$DOCKER_IMAGE:$DOCKER_TAG"

.docker-tag-latest: &docker-tag-latest
  - docker tag "$DOCKER_IMAGE:$DOCKER_TAG" "$DOCKER_IMAGE:$DOCKER_LATEST_TAG"
  - docker push "$DOCKER_IMAGE:$DOCKER_LATEST_TAG"

.cache-docker: &cache-docker
  key: "docker-${CI_COMMIT_REF_SLUG}"
  paths:
    - /var/lib/docker


# =========================
# Default
# =========================
.docker-default:
  image: docker:28.3.3
  services:
    - docker:28.3.3-dind
  cache:
    <<: *cache-docker
    policy: pull-push
    when: "on_success"

# =========================
# Jobs Docker
# =========================

.docker-lint:
  stage: lint
  image: hadolint/hadolint:latest-alpine
  script:
    - hadolint --no-fail -f gitlab_codeclimate ${DOCKERFILE_PATH} > docker-lint.json
  artifacts:
    name: "$CI_JOB_NAME artifacts from $CI_PROJECT_NAME on $CI_COMMIT_REF_SLUG"
    when: always
    reports:
      codequality:
        - docker-lint.json
  interruptible: true

.docker-build-dind:
  extends: .docker-default
  stage: build
  script:
    - *docker-login
    - cd $BASE_PATH
    - *docker-build
    - docker images "$DOCKER_IMAGE"
    - docker inspect "$DOCKER_IMAGE:$DOCKER_TAG" > $CI_PROJECT_DIR/docker-image-info.txt
    - echo "✅ Docker build complete"
  artifacts:
    when: always
    paths:
      - docker-image-info.txt
    expire_in: 1 week

.docker-build-kaniko:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: [""]   # required to override default entrypoint
  variables:
    DOCKER_DEST: "$DOCKER_IMAGE:$DOCKER_TAG-kaniko"
  script:
    - echo "Building Docker image with Kaniko..."
    - /kaniko/executor --no-push --context $BASE_PATH --dockerfile $BASE_PATH/Dockerfile --destination $DOCKER_DEST  
    - echo "✅ Docker build complete"
    - echo "$DOCKER_DEST" > $CI_PROJECT_DIR/docker-image-info.txt
  artifacts:
    when: always
    paths:
      - docker-image-info.txt
    expire_in: 1 week


.docker-build-kaniko-cached:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: [""]   # required to override default entrypoint
  variables:
    DOCKER_DEST: "$DOCKER_IMAGE:$DOCKER_TAG-kaniko"
    CACHE_REPO: "$CI_REGISTRY_IMAGE/cache"   # repo dédié pour stocker les couches en cache
  script:
    - echo "Building Docker image with Kaniko (with cache)..."
    - /kaniko/executor
        --context $BASE_PATH
        --dockerfile $BASE_PATH/Dockerfile
        --destination $DOCKER_DEST
        --cache=true
        --cache-repo $CACHE_REPO
    - echo "✅ Docker build complete (cached)"
    - echo "$DOCKER_DEST" > $CI_PROJECT_DIR/docker-image-info.txt
  artifacts:
    when: always
    paths:
      - docker-image-info.txt
    expire_in: 1 week


.docker-build-podman:
  stage: build
  image:
    name: quay.io/podman/stable:latest  # image Podman officielle
    entrypoint: [""]                    # override de l'entrypoint
  variables:
    DOCKER_DEST: "$DOCKER_IMAGE:$DOCKER_TAG-podman"
  script:
    - cd $BASE_PATH
    - echo "Building Docker image with Podman..."
    - podman build -t $DOCKER_DEST .
    - echo "✅ Podman build complete"
    - echo "$DOCKER_DEST" > $CI_PROJECT_DIR/docker-image-info.txt
  artifacts:
    when: always
    paths:
      - docker-image-info.txt
    expire_in: 1 week

.docker-build-buildah:
  stage: build
  image:
    name: quay.io/buildah/stable:latest  # image Buildah officielle
    entrypoint: [""]                     # override de l'entrypoint
  variables:
    DOCKER_DEST: "$DOCKER_IMAGE:$DOCKER_TAG-buildah"
  script:
    - cd $BASE_PATH
    - echo "Building Docker image with Buildah..."
    - buildah bud -t $DOCKER_DEST .
    - echo "✅ Buildah build complete"
    - echo "$DOCKER_DEST" > $CI_PROJECT_DIR/docker-image-info.txt
  artifacts:
    when: always
    paths:
      - docker-image-info.txt
    expire_in: 1 week


.docker-build-buildkit:
  stage: build
  image:
    name: moby/buildkit:v0.23.0-rootless
    entrypoint: [ "sh", "-c" ]
  interruptible: true
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox
    DOCKER_CONFIG: /home/user/.docker
    CACHE_REPO: "$CI_REGISTRY_IMAGE/cache-buildkit"   # repo dédié pour stocker les couches en cache
    DOCKER_DEST: "$DOCKER_IMAGE:$DOCKER_TAG-buildkit"
  before_script:
    - |
      mkdir $DOCKER_CONFIG
      cat <<EOF > "$DOCKER_CONFIG/config.json"
      {
          "auths": {
              "$CI_REGISTRY": {
                  "auth": "$(echo -n "$CI_REGISTRY_USER:$CI_REGISTRY_PASSWORD" | base64  | tr -d '\n')"
              }
          }
      }
      EOF
  script:
    - cd $BASE_PATH
    - |
      buildctl-daemonless.sh build \
          --frontend=dockerfile.v0 \
          --local context=. \
          --local dockerfile=. \
          --export-cache type=registry,ref="${CACHE_REPO}:${CI_COMMIT_REF_SLUG}",mode=max \
          --import-cache type=registry,ref="${CACHE_REPO}:${CI_DEFAULT_BRANCH}" \
          --import-cache type=registry,ref="${CACHE_REPO}:${CI_COMMIT_REF_SLUG}" \
          --output type=image,name=${DOCKER_DEST},push=true


.docker-scan-trivy:
  stage: test
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  variables:
    TRIVY_SEVERITY: "CRITICAL,HIGH"   # niveaux de vulnérabilité à bloquer
    TRIVY_SKIP_DB_UPDATE: "false"
    TRIVY_EXIT_CODE: "1"              # exit code != 0 si vulnérabilités détectées
    TRIVY_IGNORE_UNFIXED: "true"
    TRIVY_CACHE_DIR: "$CI_PROJECT_DIR/.trivycache"
    TRIVY_FORMAT: "json"             # table, json, sarif (SARIF = export GitLab Security Dashboard)
    DOCKER_DEST: "$DOCKER_IMAGE:$DOCKER_TAG"
  before_script:
    - mkdir -p $HOME/.docker
    - |  
      cat <<EOF > "$HOME/.docker/config.json"
      {
          "auths": {
              "$CI_REGISTRY": {
                  "auth": "$(echo -n "$CI_REGISTRY_USER:$CI_REGISTRY_PASSWORD" | base64  | tr -d '\n')"
              }
          }
      }
      EOF
  script:
    - set -euo pipefail
    - echo "🔍 Scanning image $DOCKER_DEST from registry..."
    - trivy image --cache-dir=$TRIVY_CACHE_DIR --severity=$TRIVY_SEVERITY --ignore-unfixed="$TRIVY_IGNORE_UNFIXED" --format=$TRIVY_FORMAT --skip-db-update=$TRIVY_SKIP_DB_UPDATE --exit-code=$TRIVY_EXIT_CODE --output=trivy-report.$TRIVY_FORMAT $DOCKER_DEST
  artifacts:
    when: always
    reports:
      dependency_scanning: trivy-report.$TRIVY_FORMAT
    paths:
      - trivy-report.$TRIVY_FORMAT
    expire_in: 1 week


.docker-test:
  extends: .docker-default
  stage: test
  script:
    - *docker-login
    - docker run --rm "$DOCKER_IMAGE:$DOCKER_TAG" echo "✅ Container runs"
    - echo "✅ Docker test complete"

.docker-deploy:
  extends: .deploy-job-template
  stage: deploy
  script:
    - *docker-build
    - *docker-push
    - if [ "$CI_COMMIT_BRANCH" == "main" ]; then
        *docker-tag-latest ;
      fi
    - echo "✅ Docker image pushed"
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: manual
      allow_failure: false

---

