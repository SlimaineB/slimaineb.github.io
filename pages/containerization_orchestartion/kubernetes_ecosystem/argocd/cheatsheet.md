---
layout: page
title: ArgoCd Cheat Sheet
nav_order: 2
parent: ArgoCd
permalink: /kubernative/argocd/cheatsheet
---

# ⚡ ArgoCD Cheat Sheet

## 🚀 Basic Commands

{% highlight bash %}
argocd version                        # Show ArgoCD client and server version
argocd login <server> --username <user> --password <pass>   # Login to ArgoCD server
argocd account get-user                # Show current user info
argocd logout <server>                 # Logout from ArgoCD server
{% endhighlight %}

---

## 📂 Applications Management

{% highlight bash %}
# Create a new app
argocd app create <app-name> \
  --repo <repo-url> \
  --path <path-in-repo> \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace <namespace>

# List applications
argocd app list

# Get app status
argocd app get <app-name>

# Delete an application
argocd app delete <app-name>
{% endhighlight %}

---

## 🔄 Sync & Rollback

{% highlight bash %}
# Sync app to the target state
argocd app sync <app-name>

# Auto-sync mode
argocd app set <app-name> --sync-policy automated

# Rollback to previous revision
argocd app rollback <app-name> <revision>

# Compare live vs desired state
argocd app diff <app-name>
{% endhighlight %}

---

## ⚙️ Configuration & Secrets

{% highlight bash %}
# Set app parameters / override values
argocd app set <app-name> -p key=value

# Set repository credentials
argocd repo add <repo-url> --username <user> --password <pass>

# Show application manifests
argocd app manifests <app-name>

# Manage clusters
argocd cluster list
argocd cluster add <context-name>
{% endhighlight %}

---

## ⚡ CI/CD Environment Variables

Useful for automated pipelines (non-interactive, plain output):

{% highlight bash %}
export ARGOCD_SERVER=argocd.example.com
export ARGOCD_USERNAME=admin
export ARGOCD_PASSWORD=SuperSecret
export ARGOCD_OPTS="--grpc-web"    # for CI/CD or proxy environments
export ARGOCD_INSECURE=true        # disable TLS verification in test env
{% endhighlight %}

---

## 📝 Best Practices

- Use **GitOps workflow**: repository as single source of truth  
- Enable **automated sync** for non-critical environments, manual sync for prod  
- Use **namespaces and RBAC** to isolate environments  
- Keep **ArgoCD CLI version in CI/CD pipelines** aligned with server  
- Monitor **application health & sync status** regularly  
- Combine with **Helm / Kustomize** for templated apps  
- Use **secret management** (SealedSecrets, SOPS) instead of plaintext  

---

