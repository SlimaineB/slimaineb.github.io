---
layout: page
title: Helm Cheat Sheet
nav_order: 2
parent: Helm
permalink: /kubernative/helm/cheatsheet
---

# ⚡ Helm Cheat Sheet

## 🚀 Basic Commands

{% highlight bash %}
helm version                        # Show Helm version
helm help                           # Show help
helm repo list                       # List Helm repositories
helm repo add <name> <url>           # Add new repository
helm repo update                     # Update all repositories
helm search repo <keyword>           # Search charts in repos
helm search hub <keyword>            # Search charts in Helm Hub
{% endhighlight %}

---

## 📦 Chart Management

{% highlight bash %}
helm create <chart-name>            # Create a new chart skeleton
helm package <chart-dir>            # Package chart into a tgz
helm inspect <chart>                # Inspect chart details
helm show values <chart>            # Show default values.yaml
helm lint <chart>                   # Check chart for errors
{% endhighlight %}

---

## 🛠️ Install & Upgrade

{% highlight bash %}
helm install <release> <chart> -f values.yaml      # Install chart with custom values
helm upgrade <release> <chart> -f values.yaml      # Upgrade release
helm upgrade --install <release> <chart> -f values.yaml # Install if not exists
helm uninstall <release>                            # Delete release
helm list                                         # List all releases
helm status <release>                             # Show release status
{% endhighlight %}

---

## 🔄 Rollback & History

{% highlight bash %}
helm history <release>                # Show release history
helm rollback <release> <revision>   # Rollback to a previous revision
helm diff upgrade <release> <chart>  # Show differences before upgrade (requires helm-diff plugin)
{% endhighlight %}

---

## ⚙️ Configuration & Values

{% highlight bash %}
helm get values <release>            # Show values used by release
helm get all <release>               # Show full release info
helm get manifest <release>          # Show generated manifests
helm template <chart> -f values.yaml # Render templates locally without deploying
{% endhighlight %}

---

## 🧰 Repositories & Plugins

{% highlight bash %}
helm repo add stable https://charts.helm.sh/stable
helm plugin list                      # List installed plugins
helm plugin install <url|tgz>         # Install plugin
helm plugin update <name>             # Update plugin
{% endhighlight %}

---

## ⚡ CI/CD Environment Variables

Useful for automated pipelines (non-interactive, plain output):

{% highlight bash %}
export HELM_HOME=~/.helm               # Custom Helm home directory
export HELM_NAMESPACE=dev              # Default namespace for releases
export HELM_DRIVER=configmap           # Store Helm release info in ConfigMap (K8s native)
export HELM_NO_UPDATE_CHECK=true       # Disable automatic repo update check
{% endhighlight %}

---

## 📝 Best Practices

- Always specify **chart version** when installing/upgrading  
- Use **values.yaml** files for environment-specific configuration  
- Keep **charts in version control**  
- Use **CI/CD pipelines** for automated release management  
- Prefer **helm template** for dry-run and CI validation  
- Scan charts for security issues (e.g., check images for vulnerabilities)  
- Use **namespaces** to isolate environments (dev/staging/prod)  
- Automate **rollback procedures** in pipelines  

---
