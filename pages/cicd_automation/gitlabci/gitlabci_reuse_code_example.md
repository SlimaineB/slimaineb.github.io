---
layout: page
title: GitlabCi Reuse Code Example
parent: GitlabCi
permalink: /cicd_automation/gitlabci/gitlabci_reuse_code_example
nav_order: 4
---

Let’s focus now on **reusable code in GitLab CI/CD**, which allows you to define job templates, include files, or extend jobs so that you don’t repeat scripts, variables, or stages.

---

## 1️⃣ **Reusable Job Templates with `extends`**

You can define a base job and reuse it in multiple jobs:

```yaml
# Base build job
.build_template:
  stage: build
  image: node:20
  script:
    - npm install
    - npm run build
  cache:
    paths:
      - node_modules/

# Reuse for frontend build
build_frontend:
  extends: .build_template
  script:
    - echo "Building frontend"
    - npm run build:frontend

# Reuse for backend build
build_backend:
  extends: .build_template
  script:
    - echo "Building backend"
    - npm run build:backend
```

**✅ Key point:** The `script` section can be overridden while keeping shared logic (image, cache, stage, etc.).

---

## 2️⃣ **Reusable Variables per Job or Environment**

Define a base variable block, then override per job:

```yaml
.variables_base:
  variables:
    NODE_ENV: "development"
    API_URL: "https://dev.api.example.com"

build_frontend:
  extends: .variables_base
  script:
    - echo "API is $API_URL"
    - npm run build

deploy_prod:
  extends: .variables_base
  variables:
    NODE_ENV: "production"
    API_URL: "https://api.example.com"
  script:
    - echo "Deploying to $API_URL"
```

**✅ Key point:** You can mix reusable variables with per-job overrides.

---

## 3️⃣ **Include External CI Files for Reuse**

You can split your GitLab CI into multiple files and include them:

```yaml
# .gitlab-ci.yml
include:
  - local: 'ci-templates/build.yml'
  - local: 'ci-templates/deploy.yml'
```

Then in `ci-templates/build.yml`:

```yaml
.build_template:
  stage: build
  script:
    - echo "Building project"
```

And in `ci-templates/deploy.yml`:

```yaml
.deploy_template:
  stage: deploy
  script:
    - echo "Deploying project"
```

Now your main `.gitlab-ci.yml` is clean and modular.

---

## 4️⃣ **Reusable Jobs with `rules` and Parameters**

With GitLab 14+, you can define **parametrized reusable jobs**:

```yaml
# .gitlab-ci.yml
stages:
  - build
  - deploy

.build_template:
  stage: build
  script:
    - echo "Building project version $VERSION"

build_v1:
  extends: .build_template
  variables:
    VERSION: "1.0.0"

build_v2:
  extends: .build_template
  variables:
    VERSION: "2.0.0"
```

**✅ Key point:** You can run multiple versions or environments with minimal duplication.

---

## 5️⃣ **Reusable Scripts via `before_script` and `after_script`**

```yaml
.default_job:
  before_script:
    - echo "Setup environment"
    - npm install
  after_script:
    - echo "Cleanup"

build_frontend:
  extends: .default_job
  script:
    - npm run build:frontend

test_backend:
  extends: .default_job
  script:
    - npm run test
```

`before_script` and `after_script` are reusable across multiple jobs.

---
