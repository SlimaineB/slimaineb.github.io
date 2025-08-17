---
layout: page
title: Tunning Python Images
nav_order: 4
parent: Best Practices
permalink: /kubernative/docker/tunning-python-image
---

Here’s an **enhanced step-by-step Python Docker image optimization tutorial** in English, including a simple Python application, its `requirements.txt`, detailed explanations, professional tuning tips, and a `Makefile` to test each step.

---

# Example Python Application

**app.py:**

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, Docker!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

**requirements.txt:**

```
flask==2.3.2
```

This small Flask app will serve as the test application for all Dockerfile optimizations.

---

# Step 0: Base Python image

**Dockerfile.base:**

```Dockerfile
FROM python:3.12
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . ./
CMD ["python", "app.py"]
```

* **Explanation:** Uses the full Python image. Simple, convenient, but very large (\~900MB). No optimizations applied yet.

---

# Step 1: Slim image with proper layer ordering

**Dockerfile.slim:**

```Dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . ./
CMD ["python", "app.py"]
```

* **Explanation:**

  * Switch to slim image reduces base size (\~180MB).
  * Copying `requirements.txt` first ensures Docker caching is effective.
  * `--no-cache-dir` avoids pip cache in the image.

---

# Step 2: Multi-stage build to remove build dependencies

**Dockerfile.multi:**

```Dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt ./
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
COPY . ./
CMD ["python", "app.py"]
```

* **Explanation:**

  * Builder stage installs dependencies with build tools.
  * Runtime stage only copies installed packages, resulting in smaller final image (\~150MB).

---

# Step 3: Alpine minimal

**Dockerfile.alpine:**

```Dockerfile
FROM python:3.12-alpine
WORKDIR /app
RUN apk add --no-cache gcc musl-dev libffi-dev
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . ./
CMD ["python", "app.py"]
```

* **Explanation:**

  * Alpine base is very small (\~55MB).
  * Only necessary OS packages are installed.
  * Great for lightweight images, but may require additional build dependencies for some Python packages.

---

# Step 3b: Distroless

**Dockerfile.distroless:**

```Dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt ./
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt
COPY . ./

FROM gcr.io/distroless/python3
WORKDIR /app
COPY --from=builder /install /usr/local
COPY . ./
CMD ["app.py"]
```

* **Explanation:**

  * Distroless images contain only runtime dependencies (\~40MB).
  * Provides minimal attack surface and very small image size.

---

# Step 3c:  Optimized Debian-based image with apt tuning

**Dockerfile.optimized:**

```Dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt ./

# Install only necessary packages, remove cache, no recommended packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libffi-dev && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt
COPY . ./
CMD ["python", "app.py"]
```

* **Size:** \~140MB
* **Advanced Tips:**

  * `--no-install-recommends` minimizes extra packages.
  * Clean apt cache to reduce image size.
  * Install build tools only when needed.

---

# Step 4: Distroless production image with advanced tuning

**Dockerfile.final:**

```Dockerfile
# Builder stage
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt ./
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt
COPY . ./

# Final distroless stage
FROM gcr.io/distroless/python3
WORKDIR /app
COPY --from=builder /install /usr/local
COPY --chown=nonroot:nonroot . ./
USER nonroot
ENV PYTHONUNBUFFERED=1
HEALTHCHECK CMD curl --fail http://localhost:5000/ || exit 1
CMD ["app.py"]
```

* **Size:** \~40MB
* **Expert Optimizations:**

  * Minimal distroless runtime.
  * Non-root user.
  * `HEALTHCHECK` for orchestration.
  * Small, secure, production-ready image.

---

# Step 5: Measuring gains

| Step | Base    | Slim    | Multi-stage | Alpine | Distroless |
| ---- | ------- | ------- | ----------- | ------ | ---------- |
| Size | \~900MB | \~180MB | \~150MB     | \~55MB | \~40MB     |

* **Explanation:** Progressive optimizations reduce image size by 95%+, improving pull times, storage, and security.

---

# Makefile to test each Dockerfile

**Makefile:**

```makefile
APP_NAME=myapp
PORT=5000

all: base slim multi alpine distroless

base:
	docker build -f Dockerfile.base -t $(APP_NAME):base .
	docker run --rm -p $(PORT):5000 $(APP_NAME):base

slim:
	docker build -f Dockerfile.slim -t $(APP_NAME):slim .
	docker run --rm -p $(PORT):5000 $(APP_NAME):slim

multi:
	docker build -f Dockerfile.multi -t $(APP_NAME):multi .
	docker run --rm -p $(PORT):5000 $(APP_NAME):multi

alpine:
	docker build -f Dockerfile.alpine -t $(APP_NAME):alpine .
	docker run --rm -p $(PORT):5000 $(APP_NAME):alpine

distroless:
	docker build -f Dockerfile.distroless -t $(APP_NAME):distroless .
	docker run --rm -p $(PORT):5000 $(APP_NAME):distroless


optimized:
	docker build -f Dockerfile.optimized -t $(APP_NAME):optimized .
	docker run --rm -p $(PORT):5000 $(APP_NAME):optimized

final:
	docker build -f Dockerfile.final -t $(APP_NAME):final .
	docker run --rm -p $(PORT):5000 $(APP_NAME):final


clean:
	docker rmi -f $(APP_NAME):base $(APP_NAME):slim $(APP_NAME):multi $(APP_NAME):alpine $(APP_NAME):distroless || true
```

* **Explanation:**

  * Each target builds and runs the corresponding Dockerfile.
  * `all` target runs all steps sequentially.
  * `clean` removes all images to free up space.

