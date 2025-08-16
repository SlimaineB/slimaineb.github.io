---
layout: page
title: Kustomize Cheat Sheet
nav_order: 2
parent: Kustomize
permalink: /kubernative/kustomize/cheatsheet
---


# ⚡ Kustomize Cheat Sheet

## 🚀 Basic Commands

{% highlight bash %}
kustomize version                     # Show Kustomize version
kustomize build <dir>                 # Render manifests from kustomization.yaml
kustomize edit add resource <file>    # Add resource to kustomization
kustomize edit set namespace <ns>     # Set default namespace
kustomize edit set nameprefix <prefix> # Set name prefix for resources
kustomize edit set nameSuffix <suffix> # Set name suffix
{% endhighlight %}

---

## 📂 Resources & Overlays

{% highlight bash %}
# Directory structure
base/
  deployment.yaml
  service.yaml
  kustomization.yaml
overlays/
  dev/
    kustomization.yaml
  staging/
    kustomization.yaml
  prod/
    kustomization.yaml

# Build overlay
kustomize build overlays/dev         # Render dev environment manifests
kustomize build overlays/prod        # Render prod environment manifests
{% endhighlight %}

---

## 🔄 Patches & Transformations

{% highlight bash %}
# Patch deployment image
kustomize edit add patch deployment-patch.yaml

# Change replicas
kustomize edit set replicas deployment-name 3

# Set common labels/annotations
kustomize edit set label app=myapp
kustomize edit set annotation owner=team

# Apply secret generator
kustomize edit add secret secret-name --from-literal=password=SuperSecret

# Apply configmap generator
kustomize edit add configmap config-name --from-file=app.conf
{% endhighlight %}

---

## 🛠️ Integration with kubectl

{% highlight bash %}
kubectl apply -k overlays/dev         # Apply kustomize overlay
kubectl diff -k overlays/staging      # Show changes before applying
kubectl delete -k overlays/prod       # Delete all resources in overlay
{% endhighlight %}

---

## ⚡ CI/CD Environment Variables

Useful for automated pipelines (non-interactive, plain output):

{% highlight bash %}
export KUSTOMIZE_PLUGIN_HOME=~/.kustomize/plugins  # Custom plugin directory
export KUSTOMIZE_OUTPUT_FORMAT=yaml                # Output YAML
export KUSTOMIZE_NAMESPACE=dev                     # Default namespace
export KUSTOMIZE_NO_COLOR=true                     # Disable colors for CI logs
{% endhighlight %}

---

## 📝 Best Practices

- Keep **base** and **overlays** directories clean and versioned separately  
- Use **patches** for environment-specific changes instead of duplicating resources  
- Prefer **generators** for secrets and configmaps  
- Validate generated manifests before applying (`kustomize build | kubectl apply --dry-run=client`)  
- Automate builds in **CI/CD pipelines**  
- Combine with **Helm charts** if necessary (`helm template | kustomize build`)  
- Use **namespaces, labels, and annotations consistently**  

---
