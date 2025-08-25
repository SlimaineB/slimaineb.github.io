---
layout: page
title: Terraform Checkov Security Scan
nav_order: 3
parent: Terraform
permalink: /iac/terraform/checkov
---

# 🔒 Terraform Security Scanning with Checkov

Ensure your Terraform code follows security best practices with **Checkov**, an open-source static code analysis tool.

---

## 1️⃣ Example Terraform Code

```hcl
# main.tf

# Insecure S3 bucket example
resource "aws_s3_bucket" "bad_example" {
  bucket = "my-unsecure-bucket"
}

# Secure S3 bucket example
resource "aws_s3_bucket" "good_example" {
  bucket = "my-secure-bucket"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "my-logs-bucket"
    target_prefix = "log/"
  }

  lifecycle_rule {
    id      = "log"
    enabled = true
    prefix  = "log/"
    expiration {
      days = 90
    }
  }
}
```

---

## 2️⃣ Running Checkov

Install Checkov (Python pip):

```bash
pip install checkov
```

Scan your Terraform directory:

```bash
checkov -d .
```

**Sample output:**

```
Check: CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
        FAILED for resource: aws_s3_bucket.bad_example

Check: CKV_AWS_19: "Ensure all data stored in the S3 bucket is securely encrypted at rest"
        FAILED for resource: aws_s3_bucket.bad_example

Check: CKV_AWS_21: "Ensure all data stored in the S3 bucket is versioned"
        FAILED for resource: aws_s3_bucket.bad_example

Passed checks: 4, Failed checks: 3
```

✅ `good_example` passes all checks.

---

## 3️⃣ Integrating Checkov in Pre-commit

1. Install **pre-commit**:

```bash
pip install pre-commit
```

2. Add `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/bridgecrewio/checkov
    rev: 2.3.320  # Use latest version
    hooks:
      - id: checkov
        args: ["--quiet"]
```

3. Install the pre-commit hooks:

```bash
pre-commit install
```

4. Now Checkov runs automatically before each commit.

---

## 4️⃣ CI/CD Pipeline Example (GitLabCi)

Create `.gitlab-ci.yml`:

```yaml
stages:
  - validate
  - security

variables:
  TF_VERSION: "1.7.6"
  CHECKOV_VERSION: "2.3.320"

before_script:
  - apk add --no-cache python3 py3-pip git bash
  - pip3 install --upgrade pip
  - pip3 install "checkov==$CHECKOV_VERSION"
  - terraform --version || apk add --no-cache terraform="$TF_VERSION"

validate:
  stage: validate
  script:
    - terraform init -backend=false
    - terraform fmt -check
    - terraform validate
  allow_failure: false

checkov:
  stage: security
  script:
    - checkov -d . -o json > checkov-report.json
  artifacts:
    paths:
      - checkov-report.json
    reports:
      dotenv: checkov-report.json

```

✅ This CI pipeline automatically scans your Terraform code for security issues and uploads a JSON report.

---

You can also fail the pipeline in case of security issue:

```yaml
checkov:
  stage: security
  script:
    - checkov -d . --quiet --exit-zero  # use exit-zero if you want to report without failing
```

---

* Use **JSON, JUnit, or SARIF** output for CI dashboards:

```bash
checkov -d . -o sarif > checkov.sarif
```

* Combine with **terraform fmt** and **terraform validate** in CI for a complete pre-deploy validation.

---


### 🔧 Skip Ckecks Locally

* **Skip specific checks** for testing:

```hcl
# checkov:skip=CKV_AWS_19:Testing bucket only
resource "aws_s3_bucket" "test" {
  bucket = "skip-check"
}
```

---

### 🔧 Skip Ckecks Globally

If you want to **ignore specific Checkov rules for the entire project**, you can do it **globally** using a configuration file. This is the cleanest way for a full repo.


## 1️⃣ Using `checkov.yaml` (recommended)

Create a `checkov.yaml` file at the root of your project:

```yaml
skip_checks:
  - CKV_AWS_18   # Skip S3 logging check
  - CKV_AWS_19   # Skip S3 encryption check
  - CKV_AWS_21   # Skip S3 versioning check
```

* Checkov will **skip these rules for all resources** in the project.
* Works for **CLI runs, CI/CD pipelines, and pre-commit hooks** automatically.

---

## 2️⃣ Using CLI argument globally

If you don’t want a config file, you can **always pass `--skip-check`** in your scripts or CI/CD:

```bash
checkov -d . --skip-check CKV_AWS_18,CKV_AWS_19,CKV_AWS_21
```

* This will skip the rules for the **entire scan**.

---

## 3️⃣ Using Environment Variable

Set an environment variable in your shell or CI/CD:

```bash
export CHECKOV_SKIP_CHECK=CKV_AWS_18,CKV_AWS_19,CKV_AWS_21
checkov -d .
```

* Works in GitLab CI/CD, GitHub Actions, local dev environments.
* Keeps your command clean and avoids long CLI arguments.

---



* Prefer `checkov.yaml` if you want **project-wide consistency** and avoid forgetting skips in CI/CD.
* Always **document why a rule is skipped** in comments or repo README so security reviewers understand it.

---
