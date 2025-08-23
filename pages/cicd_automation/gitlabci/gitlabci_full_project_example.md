---
layout: page
title: GitlabCi Full Project Example
parent: GitlabCi
permalink: /cicd_automation/gitlabci/gitlabci_full_project_example
nav_order: 1
---

# 🛠️ CI/CD GitLab **complet** avec Python `uv`, Couverture, Sécurité (Bandit, pip-audit, Trivy), Kaniko et push vers **AWS ECR**

Ce pack fournit un pipeline **de bout en bout** : lint → tests **avec coverage** → scans **SAST/Deps/Secrets** → **build image** (pré-push) → **scan image** → **push ECR** (OIDC recommandé).

---

## 1) `Makefile`

```makefile
PY_VERSION=3.12
IMAGE_NAME=local/demo:dev

.PHONY: install dev test lint cov audit bandit secrets docker-build

install:
	uv sync --no-dev

dev:
	uv sync --dev

test:
	uv run pytest -q

cov:
	uv run pytest -q --cov=. --cov-report=term-missing --cov-report=xml:coverage.xml

lint:
	uv run ruff check .

audit:
	uv run pip-audit -r <(uv export --format=requirements) --progress-spinner=off || true

bandit:
	uv run bandit -q -r . -c pyproject.toml || true

secrets:
	docker run --rm -v $$PWD:/repo -w /repo ghcr.io/trufflesecurity/trufflehog:latest filesystem --no-update --fail --only-verified . || true

docker-build:
	docker build -t $(IMAGE_NAME) .
```

> Les cibles `audit`, `bandit`, `secrets` retournent `0` localement par défaut (via `|| true`) pour ne pas bloquer votre dev. En CI, elles **échouent** si des findings sont détectés.

---

## 2) `.gitlab-ci.yml` — Lint, Tests + **Coverage**, Sécurité, Build, Scan Image, Push ECR

```yaml
stages: [validate, test, security, build, scan_image, package]

variables:
  PY_VERSION: "3.12"
  UV_CACHE_DIR: "/root/.cache/uv"
  AWS_REGION: "eu-west-1"         # ⚠️ Ajustez
  AWS_ACCOUNT_ID: "123456789012"   # ⚠️ Ajustez
  ECR_REPOSITORY: "$CI_PROJECT_PATH_SLUG"
  IMAGE_TAG: "$CI_COMMIT_SHORT_SHA"
  IMAGE_URI: "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG"
  KANIKO_CACHE_REPO: "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:cache"
  # Trivy: seuil de gravité
  TRIVY_SEVERITY: "HIGH,CRITICAL"

.default_rules: &default_rules
  rules:
    - if: "$CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS"
      when: on_success
    - if: "$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH"
      when: on_success

.cache_uv: &cache_uv
  cache:
    key: "uv-${CI_COMMIT_REF_SLUG}"
    paths: [ .venv/, .uv/, ${UV_CACHE_DIR}/ ]
    policy: pull-push

# ------------------------------
#  VALIDATE
# ------------------------------
validate:ruff:
  stage: validate
  image: "ghcr.io/astral-sh/uv:python${PY_VERSION}-bookworm"
  <<: *default_rules
  <<: *cache_uv
  script:
    - uv --version
    - uv sync --dev
    - uv run ruff check .

validate:pyproject:
  stage: validate
  image: "ghcr.io/astral-sh/uv:python${PY_VERSION}-bookworm"
  <<: *default_rules
  script:
    - test -f pyproject.toml || (echo "pyproject.toml manquant" && exit 1)

# ------------------------------
#  TESTS + COVERAGE
# ------------------------------
unit-tests:
  stage: test
  image: "ghcr.io/astral-sh/uv:python${PY_VERSION}-bookworm"
  <<: *default_rules
  <<: *cache_uv
  artifacts:
    when: always
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
    paths: [ coverage.xml ]
    expire_in: 7 days
  script:
    - uv sync --dev --frozen || uv sync --dev
    - uv run pytest -q --maxfail=1 --disable-warnings \
        --cov=. --cov-report=term-missing \
        --cov-report=xml:coverage.xml \
        --junitxml=junit.xml
  coverage: '/^TOTAL\s+\d+\s+\d+\s+\d+\s+(\d+%)/'

# ------------------------------
#  SÉCURITÉ (SAST / Dépendances / Secrets)
# ------------------------------
security:bandit:
  stage: security
  image: "ghcr.io/astral-sh/uv:python${PY_VERSION}-bookworm"
  <<: *default_rules
  script:
    - uv sync --dev
    - uv run bandit -q -r . -c pyproject.toml -f sarif -o bandit.sarif || (echo "Bandit findings" && exit 1)
  artifacts:
    when: always
    paths: [ bandit.sarif ]
    expire_in: 7 days

security:deps:
  stage: security
  image: "ghcr.io/astral-sh/uv:python${PY_VERSION}-bookworm"
  <<: *default_rules
  script:
    - uv --version
    - uv export --format=requirements > requirements.txt
    - uv run pip-audit -r requirements.txt --progress-spinner=off --format sarif -o pip-audit.sarif || (echo "Vuln deps" && exit 1)
  artifacts:
    when: always
    paths: [ pip-audit.sarif, requirements.txt ]
    expire_in: 7 days

security:secrets:
  stage: security
  image: ghcr.io/trufflesecurity/trufflehog:latest
  <<: *default_rules
  script:
    - trufflehog filesystem --no-update --json --only-verified . | tee trufflehog.json
    - test ! -s trufflehog.json || (echo "Secrets détectés" && exit 1)
  artifacts:
    when: always
    paths: [ trufflehog.json ]
    expire_in: 7 days

# ------------------------------
#  BUILD (image tar pour scan)
# ------------------------------
build:image-tar:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:latest
    entrypoint: [""]
  variables:
    DOCKER_CONFIG: "/kaniko/.docker"
  script:
    - /kaniko/executor \
        --context "$CI_PROJECT_DIR" \
        --dockerfile "$CI_PROJECT_DIR/Dockerfile" \
        --no-push \
        --tarPath "$CI_PROJECT_DIR/image.tar" \
        --cache=true \
        --cache-repo "$KANIKO_CACHE_REPO" \
        --snapshotMode=redo --use-new-run --single-snapshot
  artifacts:
    paths: [ image.tar ]
    expire_in: 1 day
  rules:
    - if: "$CI_COMMIT_BRANCH"

# ------------------------------
#  SCAN IMAGE (Trivy) — blocant sur HIGH/CRITICAL
# ------------------------------
scan:image:
  stage: scan_image
  needs: [build:image-tar]
  image: aquasec/trivy:latest
  script:
    - trivy --version
    - trivy image --input image.tar --severity $TRIVY_SEVERITY --exit-code 1 --format sarif -o trivy.sarif
  artifacts:
    when: always
    paths: [ trivy.sarif ]
    expire_in: 7 days

# ------------------------------
#  PRÉPARE AUTH ECR (OIDC ou Access Keys)
# ------------------------------
prepare:ecr-docker-config:
  stage: package
  image: amazon/aws-cli:2
  needs: [scan:image]
  script:
    - mkdir -p .docker .aws
    # OIDC (recommandé)
    - |
      if [ -n "$AWS_ROLE_TO_ASSUME" ]; then
        echo "AssumeRoleWithWebIdentity via OIDC..."
        aws sts assume-role-with-web-identity \
          --role-arn "$AWS_ROLE_TO_ASSUME" \
          --role-session-name "gitlab-oidc-$CI_JOB_ID" \
          --web-identity-token "$CI_JOB_JWT_V2" \
          --duration-seconds 3600 > /tmp/creds.json
        export AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId /tmp/creds.json)
        export AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey /tmp/creds.json)
        export AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken /tmp/creds.json)
      fi
    # Fallback: Access Keys
    - |
      if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "ERROR: Fournissez AWS_ROLE_TO_ASSUME (OIDC) ou des Access Keys" && exit 1
      fi
    - aws configure set region "$AWS_REGION"
    - PASS=$(aws ecr get-login-password --region "$AWS_REGION")
    - AUTH=$(printf "AWS:%s" "$PASS" | base64 -w0)
    - |
      cat > .docker/config.json <<EOF
      {"auths": {"$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com": {"auth": "$AUTH"}}}
      EOF
  artifacts:
    paths: [ .docker/config.json ]
    expire_in: 1 hour

# ------------------------------
#  PUSH ECR (Kaniko, avec cache)
# ------------------------------
package:image-kaniko:
  stage: package
  needs: [prepare:ecr-docker-config]
  image:
    name: gcr.io/kaniko-project/executor:latest
    entrypoint: [""]
  variables:
    DOCKER_CONFIG: "/kaniko/.docker"
  script:
    - mkdir -p /kaniko/.docker
    - cp .docker/config.json /kaniko/.docker/config.json
    - /kaniko/executor \
        --context "$CI_PROJECT_DIR" \
        --dockerfile "$CI_PROJECT_DIR/Dockerfile" \
        --destination "$IMAGE_URI" \
        --cache=true --cache-repo "$KANIKO_CACHE_REPO" \
        --snapshotMode=redo --use-new-run --single-snapshot
  rules:
    - if: "$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH" # push auto sur la branche par défaut
      when: on_success
    - if: "$CI_COMMIT_TAG"                           # push sur tag = version
      variables: { IMAGE_TAG: "$CI_COMMIT_TAG" }
      when: on_success
```

---

## 3) `Dockerfile` (multi-stage, `uv`, **user non-root**)

```dockerfile
# Stage build
FROM ghcr.io/astral-sh/uv:python3.12-bookworm AS build
WORKDIR /app

# Copie des manifests pour profiter du cache
COPY pyproject.toml uv.lock* ./
RUN uv sync --frozen --no-dev || uv sync --no-dev

# Copie du code
COPY . .

# Stage runtime minimal, non-root
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
WORKDIR /app

# Dépendances système minimales
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copier l'environnement virtuel et le code
COPY --from=build /app/.venv /app/.venv
COPY . .

# Créer un utilisateur non-root
RUN useradd -r -u 10001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
```

---

## 4) `.dockerignore`

```gitignore
.venv
.uv
__pycache__
*.pyc
.git
.gitlab-ci.yml
.tests_cache
.env
*.log
.dist
build/
.coverage
.pytest_cache
node_modules
```

---

## 5) `pyproject.toml` — deps, lint, **SAST** & tests avec coverage

```toml
[project]
name = "demo-uv-fastapi"
version = "0.2.0"
requires-python = ">=3.12"

[project.dependencies]
fastapi = "^0.115.0"
uvicorn = { extras = ["standard"], version = "^0.30.0" }

[project.optional-dependencies]
dev = [
  "pytest>=8",
  "pytest-cov>=5",
  "ruff>=0.5",
  "bandit>=1.7",
  "pip-audit>=2",
]

[tool.ruff]
line-length = 100

[tool.bandit]
targets = ["."]
exclude_dirs = ["tests", ".venv", ".uv"]
```

---

## 6) Exemple minimal d’app & tests

\`\`

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}
```

\`\`

```python
from fastapi.testclient import TestClient
from app import app

def test_health():
    c = TestClient(app)
    r = c.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
```

---

## 7) Variables GitLab à configurer

- `AWS_ACCOUNT_ID` — ex: `123456789012`
- `AWS_REGION` — ex: `eu-west-1`
- `ECR_REPOSITORY` — par défaut `$CI_PROJECT_PATH_SLUG`
- **OIDC**: `AWS_ROLE_TO_ASSUME` (ARN du rôle)
- (fallback) `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, éventuellement `AWS_SESSION_TOKEN`

> Sur MR: tout s’exécute sauf le **push**. Sur `main`/tags: push activé.

---

## 8) Notes Sécurité & Qualité

- **Coverage**: exposé dans GitLab (`coverage_report: cobertura`, `coverage:` r
