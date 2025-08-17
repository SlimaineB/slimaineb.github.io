---
layout: page
title: Best Practices Python
nav_order: 3
parent: Best Practices
permalink: /kubernative/docker/bestpractises-python
---



# 1) Prep your project for reproducible builds

* **Lock dependencies**: use a `requirements.txt` with hashes, or `pip-tools`/`poetry export --with-hashes`.
* **Build a wheel for your app** (`myapp-1.2.3-py3-none-any.whl`) to avoid `pip install .`.
* **Pin the Python version** (e.g. `3.12.x`) for ABI and wheel compatibility.
* **Aggressive `.dockerignore`**: exclude `__pycache__/`, `.git/`, `*.egg-info/`, `build/`, `docs/`, etc.

---

# 2) Packaging strategies

## A. “Interpreter + deps” (classic & robust)

* Final image: `python:<version>-slim` (Debian-based).
* ✅ Debug-friendly, works with manylinux wheels.
* ❌ Heavier than a pure binary.

## B. Standalone binary (PyInstaller / PyOxidizer / PEX / Shiv)

* Final image: `distroless` (cc or base) or `scratch` (if fully static).
* ✅ Tiny, minimal attack surface.
* ❌ Trickier with C extensions, glibc vs musl issues.

👉 Rule of thumb: if you rely on **C extensions** (numpy, cryptography, psycopg2…), use **Debian slim + manylinux wheels**. Avoid Alpine unless you’re 100% sure.

---

# 3) Optimized Dockerfile patterns

## 3.1 “Interpreter + deps” (multi-stage, fast pip, non-root)

```Dockerfile
# syntax=docker/dockerfile:1.7
# -------- Builder ----------
FROM python:3.12-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc curl && \
    rm -rf /var/lib/apt/lists/*

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip wheel --no-deps --wheel-dir /wheels -r requirements.txt

# -------- Runtime ----------
FROM python:3.12-slim
RUN useradd -u 10001 -m appuser

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY --from=builder /wheels /wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-index --find-links=/wheels -r /wheels/..data/requirements.txt \
    && rm -rf /wheels

COPY dist/myapp-*.whl /tmp/
RUN pip install --no-deps /tmp/myapp-*.whl && rm /tmp/myapp-*.whl

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c 'import socket; s=socket.socket(); s.settimeout(3); s.connect(("127.0.0.1",8080)); print("OK")'

ENTRYPOINT ["python", "-m", "myapp"]
```

**Highlights**:

* Multi-stage keeps toolchains out of runtime.
* `pip wheel` → offline installs in runtime.
* BuildKit cache → super fast incremental builds.
* `USER appuser` → non-root for security.

---

## 3.2 PyInstaller → Distroless (ultra-small runtime)

```Dockerfile
# syntax=docker/dockerfile:1.7
# -------- Builder ----------
FROM python:3.12-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc patchelf upx && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt
COPY . .
RUN pip install pyinstaller && \
    pyinstaller -F -n myapp src/myapp/__main__.py && \
    strip dist/myapp || true && upx --best --lzma dist/myapp || true

# -------- Runtime ----------
FROM gcr.io/distroless/cc-debian12:nonroot
WORKDIR /app
COPY --from=builder /src/dist/myapp /app/myapp
USER nonroot:nonroot
ENTRYPOINT ["/app/myapp"]
```

**Notes**:

* `strip`/`upx` → shrink further.
* Distroless → no shell or package manager (tiny + secure).
* Validate `.so` dependencies with `ldd` in builder.

---

## 3.3 manylinux wheels for portability

```Dockerfile
# Builder
FROM quay.io/pypa/manylinux_2_28_x86_64 AS builder
# build wheels into /wheelhouse

# Runtime
FROM python:3.12-slim
COPY --from=builder /wheelhouse /wheels
RUN pip install --no-index --find-links=/wheels myapp && rm -rf /wheels
```

---

# 4) Fine-tuning

* ENV:

  * `PYTHONDONTWRITEBYTECODE=1` → no `.pyc`.
  * `PYTHONUNBUFFERED=1` → real-time logs.
  * `PIP_NO_CACHE_DIR=1` → smaller image.
* **Reduce layers**: combine `apt-get install && clean`.
* **Use uv** instead of pip (faster installs, optional).
* **Hash-locked installs**: `pip install --require-hashes`.
* **Init process**: use `tini`/`dumb-init` to handle signals in slim.
* **Fixed UID/GID** for K8s/volumes (e.g. `10001`).
* **Logs**: always stdout/stderr.
* **Locale/TZ**: `ENV LANG=C.UTF-8 TZ=UTC`.

---

# 5) Alpine: when (not) to use

* ✅ Super small.
* ❌ Painful with C-extensions (musl).
* Use **only** for pure-Python apps or carefully managed toolchains.

```Dockerfile
FROM python:3.12-alpine AS builder
RUN apk add --no-cache build-base musl-dev
```

---

# 6) Multi-arch & BuildKit

```bash
DOCKER_BUILDKIT=1 docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t registry/myapp:1.2.3 --push .
```

---

# 7) Security & compliance

* **Non-root** always.
* **Distroless** if no debugging tools required.
* **Scan images** with Trivy/Grype.
* **Add OCI labels**:

```Dockerfile
LABEL org.opencontainers.image.source="https://git.example/myapp" \
      org.opencontainers.image.version="1.2.3" \
      org.opencontainers.image.revision="$GIT_COMMIT"
```

---

# 8) Measuring gains

* `docker history` → find heavy layers.
* `docker build --progress=plain` → inspect caching.
* Typical sizes:

  * `python:3.12-slim` + deps: \~80–150 MB.
  * PyInstaller + distroless: **15–40 MB** (sometimes <10 MB).

---

# 9) Useful commands

```bash
# Build
docker build -t myapp:dev .

# Run
docker run --rm -p 8080:8080 myapp:dev

# Inspect dynamic libs
ldd dist/myapp

# See what’s heavy
docker history myapp:dev
```

---

# 10) Pro shipping checklist

* [ ] Tight `.dockerignore`
* [ ] Multi-stage, no toolchains in runtime
* [ ] Wheels prebuilt, pip cache enabled in builder
* [ ] Non-root user with fixed UID
* [ ] Healthcheck present or consciously omitted
* [ ] OCI labels + clear versioning
* [ ] Passed security scan
* [ ] Logs to stdout/stderr
* [ ] Size target met (< X MB) and startup perf OK

---

