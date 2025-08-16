---
layout: page
title: Ansible Cheat Sheet
nav_order: 2
parent: Ansible
permalink: /iac/ansible/cheatsheet
---

# ⚡ Advanced Ansible Cheat Sheet

## 🚀 Basic Commands

{% highlight bash %}
ansible all -m ping                   # Ping all hosts
ansible all -a "uptime"               # Run ad-hoc command
ansible-playbook site.yml             # Run a playbook
ansible-playbook site.yml --check     # Dry run (no changes)
ansible-playbook site.yml --diff      # Show file differences
{% endhighlight %}

---

## 📂 Inventory Management

{% highlight bash %}
ansible-inventory --list              # Show parsed inventory
ansible-inventory --graph             # Visualize host groups
ansible-inventory -i inventory.ini --list
{% endhighlight %}

**Inventory example (INI):**
{% highlight ini %}
[web]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[db]
db1 ansible_host=192.168.1.20
{% endhighlight %}

---

## 🛠️ Modules & Ad-Hoc Usage

{% highlight bash %}
ansible all -m shell -a "df -h"
ansible all -m copy -a "src=./file.conf dest=/etc/file.conf"
ansible all -m yum -a "name=httpd state=present"
{% endhighlight %}

---

## 🔍 Debugging & Verbosity

{% highlight bash %}
ansible-playbook site.yml -v          # Verbose
ansible-playbook site.yml -vvv        # Very verbose
ansible -m ping all -vvv              # Debug ad-hoc
{% endhighlight %}

---

## 📦 Roles & Galaxy

{% highlight bash %}
ansible-galaxy init myrole            # Create new role
ansible-galaxy install geerlingguy.nginx
ansible-galaxy collection install community.general
{% endhighlight %}

**Folder structure:**
{% highlight text %}
roles/
  myrole/
    tasks/
    handlers/
    templates/
    files/
    vars/
{% endhighlight %}

---

## 📜 Linting & Testing

{% highlight bash %}
ansible-lint site.yml                 # Lint playbook
ansible-playbook --syntax-check site.yml
molecule test                         # Run Molecule tests (if configured)
{% endhighlight %}

---

## ⚙️ CI/CD Environment Variables

These make Ansible behave nicely in automation:

{% highlight bash %}
# Disable interactive prompts
export ANSIBLE_FORCE_COLOR=0
export ANSIBLE_NOCOWS=1
export ANSIBLE_HOST_KEY_CHECKING=False

# Avoid retry files in CI
export ANSIBLE_RETRY_FILES_ENABLED=False

# Set default inventory or config path
export ANSIBLE_INVENTORY=./inventory.ini
export ANSIBLE_CONFIG=./ansible.cfg

# Disable fact gathering (faster runs in CI)
export ANSIBLE_GATHERING=explicit
{% endhighlight %}

---

## ⚡ Useful Flags

- `--limit <host/group>` → Run only on specific host(s)  
- `--tags <tag>` → Run only tagged tasks  
- `--skip-tags <tag>` → Skip certain tasks  
- `--start-at-task="<task name>"` → Resume from a specific task  
- `--list-hosts` → Show which hosts would be targeted  
- `--list-tasks` → Show tasks without executing  

---

## 📝 Best Practices

- Keep inventories organized (`dev`, `staging`, `prod`)  
- Use **roles** and **collections** for reusable code  
- Keep secrets in **Ansible Vault** (`ansible-vault encrypt`)  
- Always test with `--check` before applying changes  
- Use `ansible-lint` in CI/CD for quality control  
