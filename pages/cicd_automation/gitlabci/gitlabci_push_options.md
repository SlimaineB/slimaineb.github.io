---
layout: page
title: GitlabCi - Git Push Options
parent: GitlabCi
permalink: /cicd_automation/gitlabci/gitlabci_push_options
nav_order: 3
---

Refer to for more details [Gitlab Push Options](https://docs.gitlab.com/topics/git/commit/)

---

# GitLab `git push -o` Quick Tutorial

## 1️⃣ **What Are Push Options?**

Push options let you **send extra instructions to GitLab when pushing**, which can:

* Pass pipeline variables dynamically.
* Skip pipeline creation.
* Trigger specific behaviors in GitLab CI/CD.

---

## 2️⃣ **Basic Syntax**

```bash
git push <remote> <branch> -o <option>=<value>
```

* You can include **multiple `-o` options** in a single push.
* Example:

```bash
git push origin main \
  -o ci.variable="DEPLOY_ENV=staging" \
  -o ci.variable="VERSION=1.2.3"
```

---

## 3️⃣ **Main Push Options in GitLab**

| Option                  | Description                           | Example                               |
| ----------------------- | ------------------------------------- | ------------------------------------- |
| `ci.variable=KEY=VALUE` | Sets a pipeline variable              | `-o ci.variable="DEPLOY_ENV=staging"` |
| `ci.skip`               | Skips running the pipeline            | `-o ci.skip`                          |
| `merge_request.create`  | Triggers merge request pipelines      | `-o merge_request.create`             |
| `ci.job_name=VALUE`     | Set job-specific variables (advanced) | `-o ci.job_name="test_job"`           |

> Most commonly used: `ci.variable` and `ci.skip`.

---

## 4️⃣ **Accessing Push Options in the Pipeline**

GitLab exposes them through predefined variables:

* `$CI_PUSH_OPTION_COUNT` → total number of options.
* `$CI_PUSH_OPTION_0`, `$CI_PUSH_OPTION_1`, … → each option.

**Example `.gitlab-ci.yml`:**

```yaml
stages:
  - deploy

deploy:
  stage: deploy
  script:
    - echo "Number of push options: $CI_PUSH_OPTION_COUNT"
    - for i in $(seq 0 $(($CI_PUSH_OPTION_COUNT - 1))); do
        echo "Option $i: ${!CI_PUSH_OPTION_$i}";
      done
    - echo "DEPLOY_ENV=$DEPLOY_ENV, VERSION=$VERSION"
```

* GitLab automatically exports `ci.variable` options as **environment variables** (`$DEPLOY_ENV`, `$VERSION`, …).

---

## 5️⃣ **Examples**

### Pass dynamic variables:

```bash
git push origin main -o ci.variable="DEPLOY_ENV=staging" -o ci.variable="VERSION=1.2.3"
```

* Pipeline sees:

```bash
$ echo $DEPLOY_ENV
staging
$ echo $VERSION
1.2.3
```

---

### Skip a pipeline:

```bash
git push origin main -o ci.skip
```

* No pipeline will run for this push.

---

### Combine variable passing and skip:

```bash
git push origin main -o ci.variable="VERSION=1.2.3" -o ci.skip
```

* Variables are set but pipeline won’t run.

---

## ✅ **Key Tips**

1. Push options only work **with GitLab-managed repositories**.
2. Use **branch naming or commit messages** if you need human-readable metadata.
3. `ci.variable` + `ci.skip` covers **most dynamic pipeline needs**.
4. Access `$CI_PUSH_OPTION_*` for advanced parsing.

---
