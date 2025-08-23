---
layout: page
title: GitlabCi - Matrix Sample
parent: GitlabCi
permalink: /cicd_automation/gitlabci/gitlabci_matrix_example
nav_order: 6
---

Below is a **matrix build** sample pipeline.  This will test **multiple Node.js versions** and optionally multiple OS images **in parallel**, using the reusable templates we already defined.

---

```yaml
# ==========================
# Matrix Build Example
# ==========================

# Base job template for matrix builds
.matrix-build-template:
  extends: [.default-build]
  parallel:
    matrix:
      - NODE_VERSION: ["18", "20", "22"]
        OS_IMAGE: ["node:$NODE_VERSION-bullseye", "node:$NODE_VERSION-alpine"]
  script:
    - echo "Running build on Node.js $NODE_VERSION with image $OS_IMAGE"
    - nvm install $NODE_VERSION || true   # Optional if using nvm
    - npm ci
    - npm run build
  image: $OS_IMAGE
  cache:
    key: "$CI_COMMIT_REF_NAME-$NODE_VERSION"
    paths:
      - node_modules/

# Run the matrix build job
matrix_build:
  extends: .matrix-build-template
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^(main|develop)$/'
```

---

### ✅ What this does:

1. **Matrix testing**:

   * Builds run in parallel for **Node 18, 20, 22**.
   * Each Node version tests both **bullseye** and **alpine** images.
2. **Reusable template**:

   * Inherits `.default-build`, cache, and artifacts logic.
3. **Parallelism handled automatically** by GitLab CI.
4. **Flexible OS/images**: you can add more OS or Node combinations in the `matrix`.

---

### How to integrate with the previous pipeline

1. Place this **matrix build job** alongside your other build jobs.
2. It uses the same **cache and artifacts** settings from `.default-build`.
3. Works in harmony with `workflow.rules` and branch-specific rules.



