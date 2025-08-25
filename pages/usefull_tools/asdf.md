---
layout: page
title: asdf
nav_order: 1
parent: 🛠️ Useful Tools
permalink: /useful_tools/asdf
---

# 🚀 `asdf` Tutorial: Manage Multiple Language Versions

`asdf` is a **universal version manager** that allows you to install and switch between multiple versions of programming languages and CLI tools.

---

## 1. Install `asdf`

[Installation Guide](https://asdf-vm.com/guide/getting-started.html)

Check installation:

```bash
asdf version
```
---

## 2. Add Plugins

Plugins define which languages or tools `asdf` can manage.

List all available plugins:

```bash
asdf plugin list all
```

Add plugins:

```bash
asdf plugin add python
asdf plugin add nodejs
```

---

## 3. Install Versions

### Install a specific version

```bash
asdf install python 3.12.5
asdf set python  3.12.5

asdf install nodejs 20.14.0
asdf set nodejs 20.14.0
```

### Install the latest version

```bash
asdf install python latest
asdf set python latest
```

### List installed versions

```bash
asdf list python
```

### List all available versions

```bash
asdf list all python
```

---

## 4. Switch and Check Versions

```bash
asdf current python      # show current version
asdf list python         # list installed versions
asdf latest python       # show latest stable version
```

---

## 5. Uninstall Versions

```bash
asdf uninstall python 3.11.9
```

---

## 6. Update Plugins and Versions

```bash
asdf plugin update --all
```

---

## 8. Tips & Best Practices

* Use **plugins** for each language/tool you need.
* Keep plugins updated with `asdf plugin update --all`.
* `.tool-versions` files can be committed to your repo for reproducibility.

---

### ⚡ Quick Reference Table

| Action                      | Command                           |
| --------------------------- | --------------------------------- |
| List installed versions     | `asdf list <tool>`                |
| List all available versions | `asdf list all <tool>`            |
| Show latest version         | `asdf latest <tool>`              |
| Install a version           | `asdf install <tool> <version>`   |
| Install latest version      | `asdf install <tool> latest`      |  |
| Uninstall version           | `asdf uninstall <tool> <version>` |
| Update all plugins          | `asdf plugin update --all`        |

---

If you want, I can also make a **“super short cheat sheet” version** suitable for embedding directly on a website.

Do you want me to do that?
