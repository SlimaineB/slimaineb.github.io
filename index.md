---
layout: default
title: Home
nav_order: 3
---

# Welcome to my Devops Documentation

---

## 📊 Monitoring & Observability

### 🔹 Logging
- **ELK Stack**
  - Quick setup with Docker
  - Logstash pipelines & filters
  - Kibana dashboards & visualizations
- **OpenSearch**
  - Lightweight ELK alternative
  - Grafana integration
  - Security & access control
- **Fluentd / Fluent Bit**
  - Log collection & forwarding
  - Custom parsers & routing
- **Vector.dev**
  - High-performance log pipeline
  - TOML config examples

### 🔹 Metrics & Monitoring
- **Prometheus**
  - Exporters cheatsheet
  - Alertmanager setup
  - Long-term storage (Thanos, Cortex)
- **Grafana**
  - Dashboard provisioning
  - Alerting rules
  - Data sources (Prometheus, Loki, etc.)
- **Blackbox Exporter**
  - HTTP/TCP endpoint monitoring
  - Probe configuration examples

### 🔹 Tracing & Profiling
- **Jaeger / Zipkin**
  - Distributed tracing basics
  - OpenTelemetry integration
- **Pyroscope / Parca**
  - Continuous profiling
  - CPU/memory flamegraphs

---

## 📦 Containerization & Orchestration

### 🔹 Docker & Alternatives
- **Docker**
  - Essential CLI commands
  - Multi-stage builds
  - Dockerfile best practices
- **Docker Compose**
  - Local dev environments
  - Networking & volumes
- **Podman**
  - Rootless containers
  - Docker CLI compatibility
- **Buildah / Skopeo**
  - Image creation without daemon
  - Registry operations

### 🔹 Kubernetes Ecosystem
- **Kubernetes Core**
  - `kubectl` cheatsheet
  - YAML manifest templates
  - RBAC & namespaces
- **Helm**
  - Chart structure
  - Helmfile usage
  - Private repositories
- **Kustomize**
  - Overlays & patches
  - GitOps-friendly structure
- **Argo CD**
  - GitOps deployment
  - Sync strategies
  - App-of-apps pattern
- **Flux CD**
  - Helm + Kustomize workflows
  - Multi-tenancy setups
  - Notification integrations

---

## 🔐 DevSecOps & Compliance

- **Container Security**
  - Trivy, Clair, Anchore usage
  - CI integration
- **Policy Enforcement**
  - OPA/Gatekeeper
  - Kyverno rules
- **Secrets Management**
  - HashiCorp Vault
  - External Secrets Operator
  - Sealed Secrets

---

## 🚀 CI/CD & Automation

- **GitLab CI / GitHub Actions**
  - Pipeline templates
  - Secrets & variables
  - Matrix builds
- **Jenkins / Tekton / Drone**
  - Declarative pipelines
  - Plugin recommendations
- **Argo Workflows**
  - DAG-based workflows
  - Event-driven automation

---

## ☁️ Cloud & Infrastructure

- **Infrastructure as Code**
  - Terraform modules
  - Pulumi with TypeScript/Python
- **Configuration Management**
  - Ansible playbooks
  - SaltStack states
- **Crossplane**
  - Cloud provisioning via Kubernetes
  - Compositions & claims

---