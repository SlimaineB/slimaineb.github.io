---
layout: page
title: 🖥️ PipEnv
nav_order: 3
parent: 🖥️ Python
permalink: /python/pipenv
---

# 📦 Tutorial: Managing Python Projects with `pipenv`

## 1. What is `pipenv`?

`pipenv` is a tool that combines **pip** and **virtualenv** into one workflow.
It automatically creates and manages a virtual environment for your project, and keeps track of your dependencies in **Pipfile** and **Pipfile.lock** for reproducible builds.

---

## 2. Installation

Install `pipenv` globally (best via `pipx` so it’s isolated):

```bash
pipx install pipenv
```

Or with pip:

```bash
python3 -m pip install --user pipenv
```

---

## 3. Starting a Project

### Create a new project

```bash
mkdir myproject && cd myproject
pipenv install requests
```

This will:

* Create a virtual environment just for this project
* Add `requests` to your `Pipfile`
* Lock dependencies in `Pipfile.lock`

---

### Add dev dependencies

```bash
pipenv install --dev pytest
```

---

### Activate the virtual environment

```bash
pipenv shell
```

Now you are “inside” the project’s environment.

To leave:

```bash
exit
```

---

### Run a command inside the environment (without `shell`)

```bash
pipenv run python script.py
pipenv run pytest
```

---

## 4. Managing Dependencies

* Update all dependencies:

  ```bash
  pipenv update
  ```
* Install from `Pipfile.lock` (exact versions):

  ```bash
  pipenv sync
  ```

---

## 5. Useful Commands

* Show installed packages:

  ```bash
  pipenv graph
  ```
* Remove a package:

  ```bash
  pipenv uninstall requests
  ```
* Check security vulnerabilities:

  ```bash
  pipenv check
  ```

---

## 6. Why use `pipenv`?

✅ Simplifies virtual environment management
✅ Keeps dependencies reproducible with lockfiles
✅ Separates dev and prod dependencies
✅ Integrated security check

---

👉 In short: `pipenv` makes it easy to **manage project environments + dependencies together**, instead of juggling `pip` and `venv` manually.

---
