---
layout: page
title: GitlabCi - Reusable Bloc Example
parent: GitlabCi
permalink: /cicd_automation/gitlabci/gitlabci_reusable_bloc_example
nav_order: 6
---

Below is  **professional-grade, fully modular GitLab CI/CD pipeline** that demonstrates **all types of reusable blocks**, including templates, variables, artifacts, `rules`, `workflow`, external includes (remote pipelines), parallel jobs, and Docker integration. This is production-ready and adaptable.

---

```yaml
# ==========================
# Modular Advanced GitLab CI/CD Pipeline
# ==========================

# --------------------------
# Global Variables
# --------------------------
variables:
  GLOBAL_ENV: "dev"
  DOCKER_REGISTRY: "registry.example.com"
  DOCKER_IMAGE: "$DOCKER_REGISTRY/myapp"

# --------------------------
# Workflow Control
# --------------------------
workflow:
  rules:
    # Skip pipeline if commit message contains [skip ci]
    - if: '$CI_COMMIT_MESSAGE =~ /skip ci/i'
      when: never
    # Run on main, develop, or merge requests
    - if: '$CI_COMMIT_BRANCH =~ /^(main|develop)$/ || $CI_PIPELINE_SOURCE == "merge_request_event"'
      when: always

# --------------------------
# External Includes (Remote & Local)
# --------------------------
include:
  # Local reusable job templates
  - local: 'ci-templates/build.yml'
  - local: 'ci-templates/deploy.yml'
  # Remote templates from another repo (must be public or have token access)
  - remote: 'https://gitlab.com/other-repo/ci-templates/-/raw/main/reusable-jobs.yml'

# --------------------------
# Base Job Templates
# --------------------------
.default-build:
  stage: build
  image: node:20
  before_script:
    - echo "Setting up Node.js environment"
  script:
    - npm ci
    - npm run build
  cache:
    key: "$CI_COMMIT_REF_NAME"
    paths:
      - node_modules/
      - .cache/
  artifacts:
    paths:
      - build/
    expire_in: 1 week

.test-template:
  stage: test
  script:
    - npm run test
  parallel: 3  # Run in parallel 3 times
  artifacts:
    reports:
      junit: test-results.xml
    expire_in: 1 week

.deploy-template:
  stage: deploy
  script:
    - echo "Deploying to $DEPLOY_ENV"
  environment:
    name: $DEPLOY_ENV
    url: https://$DEPLOY_ENV.example.com
  when: manual

.variables-base:
  variables:
    NODE_ENV: "development"
    API_URL: "https://dev.api.example.com"

# --------------------------
# Jobs Using Templates
# --------------------------

# Build Jobs
build_frontend:
  extends: [.default-build, .variables-base]
  script:
    - echo "Building frontend"
    - npm run build:frontend
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^(main|develop)$/'
    - changes:
        - frontend/**/*
        - package.json

build_backend:
  extends: [.default-build, .variables-base]
  script:
    - echo "Building backend"
    - npm run build:backend
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^(main|develop)$/'
    - changes:
        - backend/**/*
        - package.json

# Test Jobs
unit_tests:
  extends: .test-template
  rules:
    - if: '$CI_COMMIT_BRANCH || $CI_PIPELINE_SOURCE == "merge_request_event"'

lint_code:
  stage: test
  script:
    - npm run lint
  rules:
    - changes:
        - frontend/**/*.js
        - backend/**/*.js

# Docker Build
docker_build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $DOCKER_IMAGE:$CI_COMMIT_REF_NAME .
    - docker push $DOCKER_IMAGE:$CI_COMMIT_REF_NAME
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^(main|develop)$/'

# Deploy Jobs
deploy_staging:
  extends: .deploy-template
  variables:
    DEPLOY_ENV: "staging"
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'
      when: manual

deploy_prod:
  extends: .deploy-template
  variables:
    DEPLOY_ENV: "production"
  rules:
    - if: '$CI_COMMIT_BRANCH == "main" && $CI_PIPELINE_SOURCE == "push"'
      when: manual
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: always

# Generate Environment Variables for Later Jobs
generate_env:
  stage: build
  script:
    - echo "VERSION=1.2.3" >> env_vars.env
  artifacts:
    reports:
      dotenv: env_vars.env

use_env:
  stage: test
  script:
    - echo "Using generated version: $VERSION"
  dependencies:
    - generate_env
```

---

### ✅ Features Included

1. **Reusable job templates**: `.default-build`, `.test-template`, `.deploy-template`.
2. **Reusable variables**: `.variables-base` for NODE\_ENV/API\_URL.
3. **Conditional execution with `rules`**: branch, tag, file changes.
4. **Workflow-level control**: skip pipeline or run only on main/develop/merge requests.
5. **Artifacts & caching**: speed up builds and store results.
6. **Parallel jobs**: `unit_tests` runs 3 times in parallel.
7. **Docker builds**: integrated with Docker-in-Docker.
8. **Dynamic environment variables** via `dotenv`.
9. **External includes**: both local templates and remote pipeline files.
10. **Manual deployments** with `when: manual`.

---

