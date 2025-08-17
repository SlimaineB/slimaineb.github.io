---
layout: page
title: Kubernetes Cheat Sheet
nav_order: 5
parent: Kubernetes
permalink: /kubernative/kubernetes/cheatsheet
---

# ⚡ Advanced Kubernetes Cheat Sheet

## 🚀 Basic Commands

{% highlight bash %}
kubectl version                      # Show client & server version
kubectl cluster-info                  # Cluster details
kubectl get nodes                     # List nodes
kubectl get pods                      # List pods in current namespace
kubectl get pods -A                   # List pods in all namespaces
kubectl get services                  # List services
kubectl get deployments               # List deployments
kubectl describe pod <pod-name>       # Show pod details
kubectl logs <pod-name>               # Show pod logs
kubectl exec -it <pod-name> -- bash   # Access container shell
{% endhighlight %}

---

## 📂 Namespaces & Contexts

{% highlight bash %}
kubectl get ns                        # List namespaces
kubectl create ns <name>              # Create namespace
kubectl config get-contexts           # List contexts
kubectl config use-context <context>  # Switch context
kubectl config current-context        # Show current context
{% endhighlight %}

---

## 🛠️ Deployments & Pods

{% highlight bash %}
kubectl apply -f deployment.yaml      # Apply YAML manifest
kubectl delete -f deployment.yaml     # Delete resources
kubectl rollout status deployment/<name>
kubectl rollout undo deployment/<name>  # Rollback
kubectl scale deployment <name> --replicas=5
kubectl set image deployment/<name> nginx=nginx:1.25  # Update container image
{% endhighlight %}

---

## 🔗 Services & Networking

{% highlight bash %}
kubectl get svc                        # List services
kubectl expose deployment <name> --type=LoadBalancer --port=80 --target-port=8080
kubectl port-forward svc/<service> 8080:80
kubectl get ingress                     # List ingress resources
kubectl describe ingress <name>
{% endhighlight %}

---

## 📦 ConfigMaps & Secrets

{% highlight bash %}
kubectl create configmap myconfig --from-file=app.conf
kubectl create secret generic mysecret --from-literal=password=SuperSecret
kubectl describe configmap myconfig
kubectl describe secret mysecret
kubectl get secrets
{% endhighlight %}

---

## 🔍 Debugging & Logs

{% highlight bash %}
kubectl logs -f <pod>                  # Stream logs
kubectl logs -f <pod> -c <container>   # Logs from specific container
kubectl exec -it <pod> -- sh           # Shell access
kubectl top nodes                       # Resource usage per node
kubectl top pod                         # Resource usage per pod
kubectl describe pod <pod>             # Detailed info
kubectl get events --sort-by='.metadata.creationTimestamp'
{% endhighlight %}

---

## 🔍 Create Template

Use kubectl create ... --dry-run=client -o yaml to quickly generate a template 

Generate deployment.yaml and edit it directly :

{% highlight bash %}
kubectl create deployment myapp \
  --image=nginx \
  --replicas=3 \
  --port=80 \
  --dry-run=client -o yaml > deployment.yaml
{% endhighlight %}

Deployment + Service in all.yml :

{% highlight bash %}
kubectl create deployment myapp --image=nginx --dry-run=client -o yaml > all.yaml
kubectl expose deployment myapp --port=80 --target-port=80 --type=ClusterIP --dry-run=client -o yaml >> all.yaml
{% endhighlight %}


---

## ⚙️ CI/CD Environment Variables

Useful for automated pipelines (non-interactive, plain output):

{% highlight bash %}
export KUBECONFIG=~/.kube/config       # Use custom kubeconfig
export KUBECTL_NAMESPACE=dev           # Default namespace
export KUBECTL_PLUGINS_PATH=~/.kube/plugins
export KUBECTL_NO_HEADERS=1            # Disable table headers in CI
export KUBECTL_COLOR=never              # Disable color output
{% endhighlight %}

---

## ⚡ Useful Flags

- `-n <namespace>` → Specify namespace  
- `--context <context>` → Specify cluster context  
- `--kubeconfig <file>` → Use custom kubeconfig  
- `-o yaml/json` → Output in YAML or JSON format  
- `--dry-run=client|server` → Preview changes without applying  
- `--force` → Force delete resources  
- `--grace-period=0` → Immediate deletion  

---

## 📝 Best Practices

- Always use **namespaces** for environments (dev, staging, prod)  
- Keep manifests in **version control**  
- Use **Deployments** + **ReplicaSets** for pod management  
- Prefer **Secrets** over plain text for sensitive info  
- Use **liveness/readiness probes** for stable apps  
- Monitor resource usage (`kubectl top`, metrics-server)  
- Automate deployments with **CI/CD pipelines** (GitOps, ArgoCD, Flux)  
- Test manifests with `kubectl apply --dry-run=client` before applying
