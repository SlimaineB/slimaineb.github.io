---
layout: page
title: Terraform Cheat Sheet
nav_order: 4
parent: Terraform
permalink: /iac/terraform/cheatsheet
---

# ⚡ Advanced Terraform Cheat Sheet

## 🚀 Basic Workflow

{% highlight bash %}
terraform init        # Download providers & initialize project
terraform validate    # Check configuration syntax
terraform plan        # Preview execution changes
terraform apply       # Apply changes to infrastructure
terraform destroy     # Destroy all managed resources
{% endhighlight %}

---

## 🛠️ State Management

{% highlight bash %}
terraform state list                   # List resources in state
terraform state show <resource>        # Show details of a resource in state
terraform state mv <src> <dest>        # Move/rename resource in state
terraform state rm <resource>          # Remove resource from state (keeps infra)
terraform refresh                      # Sync state with real infrastructure
{% endhighlight %}

---

## 🌍 Workspaces (Multi-Env)

{% highlight bash %}
terraform workspace list               # List all workspaces
terraform workspace new dev            # Create "dev" workspace
terraform workspace select dev         # Switch to "dev" workspace
terraform workspace show               # Show current workspace
{% endhighlight %}

---

## 📦 Modules

{% highlight bash %}
# Initialize / update modules
terraform get
terraform get -update
{% endhighlight %}

Example usage in **main.tf**:
{% highlight hcl %}
module "network" {
  source = "./modules/network"
  vpc_cidr = "10.0.0.0/16"
}
{% endhighlight %}

---

## 🔍 Debugging & Logging

{% highlight bash %}
terraform plan -out=plan.out        # Save plan to a file
terraform apply plan.out            # Apply a saved plan

# Increase verbosity
TF_LOG=DEBUG terraform plan
TF_LOG=TRACE terraform apply

# Save debug logs to a file
TF_LOG=DEBUG TF_LOG_PATH=./debug.log terraform apply
{% endhighlight %}

---

## 📜 Formatting & Style

{% highlight bash %}
terraform fmt                        # Format all .tf files
terraform fmt -recursive             # Format recursively

terraform validate                   # Validate configuration
terraform graph | dot -Tpng > graph.png  # Generate dependency graph
{% endhighlight %}

---

## 🔐 Security & Secrets

{% highlight bash %}
terraform output db_password         # Print output (be careful with secrets)
terraform output -json               # Machine-readable output

# Use environment variables for sensitive values
export TF_VAR_db_password="SuperSecret123"
{% endhighlight %}

---

## ⚙️ CI/CD Environment Variables

Use these to control Terraform behavior in pipelines (GitHub Actions, GitLab CI, Jenkins, etc.):

{% highlight bash %}
# Disable interactive approval (same as -auto-approve)
export TF_INPUT=0

# Disable colored output (useful in CI logs)
export TF_CLI_ARGS="-no-color"

# Provide default flags for all commands
export TF_CLI_ARGS_plan="-input=false -lock-timeout=300s"
export TF_CLI_ARGS_apply="-input=false -auto-approve"

# Set parallelism globally
export TF_CLI_ARGS="-parallelism=5"

# Set custom plugin/cache directory
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
{% endhighlight %}

---

## ⚡ Useful Flags

- `-auto-approve` → Skip interactive approval  
- `-lock=false` → Run without state lock (⚠️ risky)  
- `-refresh=false` → Skip refreshing state before plan/apply  
- `-parallelism=N` → Limit parallel resource operations  

---

## 📝 Best Practices

- Always run `terraform plan` before `apply`  
- Version-control your `.tf` files, but ignore:
  - `.terraform/`
  - `terraform.tfstate*`  
- Use **modules** for reusable infrastructure code  
- Use **workspaces** or remote state for multi-env setups  
- Keep secrets in environment variables or a secrets manager (not in `.tfvars`)  
