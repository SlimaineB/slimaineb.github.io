---
layout: page
title: Best Practices
nav_order: 3
parent: Docker
permalink: /kubernative/docker/bestpractises
---

## 🐳 Docker Best Practices

Optimizing Docker images is essential to get **fast, secure, and maintainable** containers.  
Here is a compilation of best practices you should apply daily.

---

### 🏗️ Image Management

- ✅ **Use official and minimal base images** (`alpine`, `ubuntu:22.04`)  
- 📌 **Pin versions** to avoid uncontrolled changes (`python:3.11-slim`)  
- 🪶 **Keep images small** with slim variants or multi-stage builds  
- 🧹 **Clean up caches and temp files** (`rm -rf /var/lib/apt/lists/*`)  
- 🏷️ **Add labels** for documentation and traceability  

```docker
LABEL maintainer="you@example.com" \
      version="1.0" \
      description="Optimized Go backend API"
```

---

#### 🚀 Multi-stage builds

Multi-stage builds let you compile in one stage and ship only what’s needed for runtime:

```docker
# Build stage
FROM golang:1.21 AS build
WORKDIR /app
COPY . .
RUN go build -o myapp

# Final image
FROM alpine:latest
WORKDIR /app
COPY --from=build /app/myapp .
CMD ["./myapp"]
```

👉 Result: a **lightweight image** without unnecessary dependencies (~10 MB instead of 1 GB).

---

### 🔒 Security

- 🚫 Avoid using `latest` (uncontrolled updates risk)  
- 👤 Run the app as a **non-root user**:  

```docker
RUN addgroup -S app && adduser -S app -G app
USER app
```

- 🔐 Regularly scan images with tools like **Trivy**, **Grype**, or **Docker Scout**  
- ⏱️ Keep base images up to date for security patches  
- 🛡️ Limit privileges: avoid exposing unused ports or volumes  

---

### ⚡ Performance & Build Optimization

- 📂 **Optimize layer order** (`COPY` then `RUN`) to leverage Docker cache  
- 🎯 Copy only what you need:  

```docker
COPY requirements.txt .
RUN pip install -r requirements.txt --no-cache-dir
COPY . .
```

- 🔄 Use `.dockerignore` to exclude unnecessary files (`.git`, `node_modules`, etc.)  
- 🏎️ Ensure **reproducible builds** with pinned dependencies (`requirements.txt`, `package-lock.json`)  

---

### 📦 Containerization Best Practices

- ⚙️ **One process per container** (Unix principle: "do one thing well")  
- 🔌 Use **environment variables** for configuration  
- 🗂️ Mount persistent data via **volumes**  
- 📊 Explicitly **expose ports** (`EXPOSE 8080`)  
- 📝 Document build & run steps in `README.md`  

---

### 🔍 Complete Optimized Example (Python FastAPI)

```docker
# Build stage
FROM python:3.11-slim AS build
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Copy source code
COPY . .

# Final image
FROM python:3.11-slim
WORKDIR /app

# Add non-root user
RUN adduser --disabled-password appuser
USER appuser

COPY --from=build /app /app

EXPOSE 8000
CMD ["python", "main.py"]
```

✅ Benefits:  
- Small image  
- Secure (no root user)  
- Faster builds thanks to caching  

---

💡 **Final Tip**:  
Combine these practices with a **CI/CD pipeline** that:  
- Builds and tags images automatically  
- Scans them for vulnerabilities  
- Pushes to a private or public registry  

---


