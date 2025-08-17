---
layout: page
title: GitlabCi - Test Locally
parent: CiCd
permalink: /cicd/gitlabci/gitlabci_local_testing
nav_order: 1
---

# 🚀 Tutorial: Using `gitlab-ci-local` to test your pipeline locally

---

**It's strongly recommended to test your pipeline locally before committing for many reasons:**

1. **💸 Save CI/CD minutes**  
   You don’t consume GitLab shared runner minutes (often limited or billed). Everything runs on your own machine.  

2. **⚡ Faster feedback**  
   No need to wait for GitLab to schedule and start jobs — tests run instantly when you execute them locally.  

3. **🛠 Easier debugging**  
   You get **direct access to logs** and can edit `.gitlab-ci.yml` + re-run immediately without extra commits/pushes.  

4. **🔍 Catch environment issues early**  
   Quickly spot missing dependencies, variables, or incorrect paths before they break the remote pipeline.  

5. **🧪 Safe experimentation**  
   Try new jobs or scripts locally without affecting the official pipeline.  

6. **👨‍💻 Works offline**  
   Even without internet access, you can validate your pipeline logic while traveling or working offline.  

7. **🧹  Keep your commit history clean** 
    Avoid broken or noisy commits.

For this purpose, there is an amazing tool called **gitlab-ci-local** . [See Official Documentation](https://github.com/firecow/gitlab-ci-local)

Here's a quick overview of how to set it up efficiently:

---

## 1. Install `gitlab-ci-local`

Make sure you have Node.js ≥ 14 installed, then:

```bash
npm install -g gitlab-ci-local
````

---

## 2. Minimal `.gitlab-ci.yml` for a Python App

Here’s a very simple pipeline with **tests, build and deploy** stages:

```yaml
stages:
  - test
  - build
  - deploy

tests:
  stage: test
  image: python:3.11
  before_script:
    - pip install -r requirements.txt
  script:
    - pytest

build:
  stage: build
  image: python:3.11
  script:
    - python setup.py sdist bdist_wheel
  artifacts:
    paths:
      - dist/

deploy:
  stage: deploy
  script:
    - echo "🚀 Deploying to $ENV environment"
  dependencies:
    - build
```

---

## 3. Run Jobs Locally

* Run only the **tests job** only:

  ```bash
  gitlab-ci-local tests
  ```

* Run the **build job** only:

  ```bash
  gitlab-ci-local build
  ```

* Run the **whole pipeline**:

  ```bash
  gitlab-ci-local
  ```

---

## 4. Environment Variables

You can pass variables exactly like GitLab does.
For example, simulate a **production deploy**:

```bash
gitlab-ci-local deploy --variable ENV=production
```

You can also define default variables in a `.gitlab-ci-local-variables.yml` or `.env` file at the root of your project.

---

👉 With this setup, you can **test your pipeline locally** (including variables) before pushing to GitLab.
