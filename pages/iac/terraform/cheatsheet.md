---
layout: page
title: Terraform Cheat Sheet
nav_order: 2
parent: Terraform
permalink: /iac/terraform/cheatsheet
---

# 📘 Terraform Cheat Sheet

## 🚀 Commandes de base

```bash
# Initialiser un projet Terraform
terraform init

# Vérifier la configuration
terraform validate

# Afficher le plan d'exécution
terraform plan

# Appliquer la configuration
terraform apply

# Détruire les ressources
terraform destroy

# Lister les workspaces
terraform workspace list

# Créer un workspace
terraform workspace new <nom>

# Changer de workspace
terraform workspace select <nom>
