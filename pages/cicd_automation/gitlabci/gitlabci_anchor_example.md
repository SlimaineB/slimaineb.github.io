---
layout: page
title: GitlabCi - Anchor Sample
parent: GitlabCi
permalink: /cicd_automation/gitlabci/gitlabci_anchor_example
nav_order: 6
---

 Using **YAML anchors & aliases** is a very clean way to make GitLab CI/CD pipelines reusable without repeating code. Anchors let you define blocks once and then reference or override them multiple times. Here’s a full example:

---

```yaml
# ==========================
# GitLab CI/CD with Anchors & Aliases
# ==========================

# --------------------------
# Anchors for reusable blocks
# --------------------------
.defaults: &defaults
  image: node:20
  before_script:
    - echo "Setting up environment"
    - npm ci
  cache:
    paths:
      - node_modules/
      - .cache/

.build_job: &build_job
  <<: *defaults
  stage: build
  script:
    - echo "Default build"
    - npm run build
  artifacts:
    paths:
      - build/
    expire_in: 1 week

.test_job: &test_job
  <<: *defaults
  stage: test
  script:
    - echo "Running tests"
    - npm run test
  parallel: 2
  artifacts:
    reports:
      junit: test-results.xml

.deploy_job: &deploy_job
  stage: deploy
  script:
    - echo "Deploying to $DEPLOY_ENV"
  environment:
    name: $DEPLOY_ENV
    url: https://$DEPLOY_ENV.example.com
  when: manual

# --------------------------
# Workflow
# --------------------------
workflow:
  rules:
    - if: '$CI_COMMIT_MESSAGE =~ /skip ci/i'
      when: never
    - when: always

# --------------------------
# Jobs using anchors & aliases
# --------------------------

build_frontend:
  <<: *build_job
  script:
    - echo "Building frontend"
    - npm run build:frontend
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^(main|develop)$/'

build_backend:
  <<: *build_job
  script:
    - echo "Building backend"
    - npm run build:backend
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^(main|develop)$/'

unit_tests:
  <<: *test_job
  rules:
    - if: '$CI_COMMIT_BRANCH || $CI_PIPELINE_SOURCE == "merge_request_event"'

lint_code:
  <<: *test_job
  stage: test
  script:
    - npm run lint
  rules:
    - changes:
        - frontend/**/*.js
        - backend/**/*.js

deploy_staging:
  <<: *deploy_job
  variables:
    DEPLOY_ENV: "staging"
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'

deploy_prod:
  <<: *deploy_job
  variables:
    DEPLOY_ENV: "production"
  rules:
    - if: '$CI_COMMIT_BRANCH == "main" && $CI_PIPELINE_SOURCE == "push"'
      when: manual
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: always
```

---

### ✅ Key Points:

1. **`&anchor`** defines reusable blocks (`&defaults`, `&build_job`, etc.).
2. **`<<: *anchor`** merges the anchor content into the job.
3. Overrides are easy: you can change `script`, `variables`, or `rules` while keeping the rest reusable.
4. Works for `build`, `test`, `deploy`, caching, artifacts, etc.
5. Clean, DRY pipeline: reduces copy-paste errors.

---

