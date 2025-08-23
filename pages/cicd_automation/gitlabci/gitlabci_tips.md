---
layout: page
title: GitlabCi Tips
parent: GitlabCi
permalink: /cicd/gitlabci/gitlabci_tips
nav_order: 3
---

## 1️⃣ `rules`: more powerful than `only/except`

`rules` allows you to trigger a job based on **very specific conditions**, such as branch, modified files, or even variables.

**Advanced example:**

```yaml
deploy_prod:
  stage: deploy
  script:
    - echo "Deploying to production"
  rules:
    - if: '$CI_COMMIT_BRANCH == "main" && $CI_PIPELINE_SOURCE == "push"'
      when: manual
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: always
    - when: never
```

**Tips:**

* `when: manual` → job is triggered manually.
* `when: delayed` → delayed execution (`start_in: 1 hour`).
* Combine with `changes` to run a job only if certain files were modified:

```yaml
test_docs:
  script: make docs
  rules:
    - changes:
      - docs/**/*.md
```

---

## 2️⃣ `workflow`: control the entire pipeline

Full sample in https://docs.gitlab.com/ci/yaml/workflow/

`workflow` allows you to decide **if the whole pipeline should run or not**. Useful for saving time and resources.

```yaml
workflow:
  rules:
    - if: '$CI_COMMIT_MESSAGE =~ /skip pipeline/i'
      when: never
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: always
```

**Tips:**

* Prevent unnecessary pipelines on temporary branches.
* Use `exists` to check if a file exists before running the pipeline:

```yaml
workflow:
  rules:
    - exists:
        - Dockerfile
        - .gitlab-ci.yml
```

---

## 3️⃣ Variables: dynamic and secure

GitLab supports **global, per-job, and dynamic variables**.

```yaml
variables:
  GLOBAL_ENV: "dev"
  DOCKER_TAG: "$CI_COMMIT_REF_NAME"
```

**Dynamic per-job variables:**

```yaml
build:
  script:
    - echo "Docker Tag: $DOCKER_TAG"
  variables:
    DOCKER_TAG: "${CI_COMMIT_REF_NAME}-build"
```

**Advanced tips:**

* Define **environment-specific variables** in `.gitlab-ci.yml` or GitLab UI for secrets/tokens.
* Use `dotenv` to share variables between jobs:

```yaml
generate_env:
  script:
    - echo "VERSION=1.2.3" >> env_vars.env
  artifacts:
    reports:
      dotenv: env_vars.env

use_env:
  script:
    - echo "Version is $VERSION"
```

---

## 4️⃣ General tips for advanced pipelines

1. **Job templates**: reuse jobs with `extends`.
2. **Build matrices**: test multiple versions or OS.
3. **Parallel jobs**: use `parallel: N` to speed up pipelines.
4. **Smart caching**: `cache:key` to share dependencies and reduce build time.
5. **Expirable artifacts**: prevent storage overload (`expire_in: 1 week`).

```yaml
build:
  stage: build
  script: make build
  cache:
    key: "$CI_COMMIT_REF_NAME"
    paths:
      - node_modules/
```

---

