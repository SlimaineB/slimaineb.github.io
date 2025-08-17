---
layout: page
title: Best Practices Java
nav_order: 3
parent: Best Practices
permalink: /kubernative/docker/bestpractises-java
---


Got it 👍 — here’s the **pro-level tutorial in English** on how to **tune a Docker image for a Java application**, whether it’s a JAR or native image (GraalVM). We’ll focus on **image size, build speed, runtime performance, security, and portability**, with ready-to-use Dockerfile patterns.

---

# 1) Prep your project for reproducible builds

* **Lock dependencies**: use Maven (`pom.xml`) or Gradle (`build.gradle`) with fixed versions.
* **Build an Uber/Fat JAR** to bundle all dependencies for easier runtime.
* **Pin the JDK version** (e.g., `17.0.x`) to avoid incompatibilities.
* **Aggressive `.dockerignore`**: exclude `target/`, `.git/`, `*.class`, `*.log`, `out/`, etc.

---

# 2) Packaging strategies

## A. JDK + JAR (classic & robust)

* Final image: `openjdk:<version>-slim`.
* ✅ Debug-friendly, compatible with most JVM apps.
* ❌ Larger image size (\~100–200MB).

## B. Native image (GraalVM)

* Final image: `distroless/java` or `scratch` if fully static.
* ✅ Tiny, minimal attack surface, fast startup.
* ❌ Complex build, native-image compilation required.

👉 Rule of thumb: use JDK slim for apps with dynamic class loading or reflection. Use GraalVM native image for microservices or CLI tools where startup time and size matter.

---

# 3) Optimized Dockerfile patterns

## 3.1 JDK + Fat JAR (multi-stage, non-root)

```Dockerfile
# -------- Builder ----------
FROM maven:3.9.2-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# -------- Runtime ----------
FROM eclipse-temurin:17-jdk-focal
RUN useradd -u 10001 -m appuser
WORKDIR /app
COPY --from=builder /app/target/myapp-*.jar ./myapp.jar
USER appuser
ENTRYPOINT ["java", "-jar", "myapp.jar"]
```

**Highlights**:

* Multi-stage keeps Maven and build tools out of runtime.
* Non-root for security.

---

## 3.2 GraalVM native image → Distroless (ultra-small runtime)

```Dockerfile
# -------- Builder ----------
FROM ghcr.io/graalvm/graalvm-ce:22.3.2 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN gu install native-image
RUN mvn clean package -Pnative

# -------- Runtime ----------
FROM gcr.io/distroless/java17-debian11
WORKDIR /app
COPY --from=builder /app/target/myapp ./myapp
USER nonroot:nonroot
ENTRYPOINT ["/app/myapp"]
```

**Notes**:

* Distroless → minimal attack surface, no shell or package manager.
* Native image → super-fast startup, very small (\~20MB).
* Validate dependencies and reflection config when building.

---

# 4) Fine-tuning

* Use `JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0"` for container-aware JVM.
* Use layered JARs (Spring Boot `LAYERS`) to leverage Docker cache.
* Non-root user with fixed UID/GID for K8s.
* Environment variables for locale and timezone: `ENV LANG=C.UTF-8 TZ=UTC`.

---

# 5) Multi-arch & BuildKit

```bash
DOCKER_BUILDKIT=1 docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t registry/myapp:1.0.0 --push .
```

---

# 6) Security & compliance

* Always run as non-root.
* Use Distroless if no shell required.
* Scan images with Trivy/Grype.
* Add OCI labels:

```Dockerfile
LABEL org.opencontainers.image.source="https://git.example/myapp" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.revision="$GIT_COMMIT"
```

---

# 7) Measuring gains

* `docker history myapp` → identify heavy layers.
* Typical sizes:

  * JDK + JAR: \~100–200 MB
  * GraalVM native image + distroless: \~15–40 MB

---

# 8) Useful commands

```bash
# Build
docker build -t myapp:dev .

# Run
docker run --rm -p 8080:8080 myapp:dev
```

---

# 9) Pro shipping checklist

* [ ] Tight `.dockerignore`
* [ ] Multi-stage, no toolchains in runtime
* [ ] Non-root user with fixed UID
* [ ] Healthcheck present if needed
* [ ] OCI labels + clear versioning
* [ ] Passed security scan
* [ ] Logs to stdout/stderr
* [ ] Image size target met and startup performance acceptable
