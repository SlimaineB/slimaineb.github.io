---
layout: page
title: 🖥️ PipX
nav_order: 2
parent: 🖥️ Python
permalink: /python/pipx
---

# 🚀 Tutorial: Using `pipx` to Install and Run Python CLI Tools

## 1. What is `pipx`?

`pipx` is a tool that helps you **install and run Python applications in isolated environments**.
Instead of mixing global installs with your projects, `pipx` creates a small virtual environment for each tool.
This keeps your system clean and avoids dependency conflicts.

---

## 2. Installation

On most systems, you can install `pipx` with `pip`:

```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

Restart your shell so that `~/.local/bin` is added to your PATH.

On Debian/Ubuntu you can also do:

```bash
sudo apt install pipx
```

---

## 3. Basic Usage

### Install a CLI tool

```bash
pipx install black
```

This creates a virtual environment just for **black** and links it into your PATH.

Now you can run:

```bash
black my_script.py
```

---

### List installed tools

```bash
pipx list
```

---

### Upgrade a tool

```bash
pipx upgrade black
```

---

### Uninstall a tool

```bash
pipx uninstall black
```

---

### Run a tool once, without installing

```bash
pipx run cowsay "Hello from pipx!"
```

---

## 4. Typical Use Cases

Use `pipx` for Python-based **command-line applications** you want to install globally, such as:

* **Formatters/Linters**: `black`, `ruff`, `mypy`
* **Project managers**: `pdm`, `poetry`
* **Utilities**: `httpie`, `yt-dlp`, `cookiecutter`

---

## 5. Why use `pipx`?

✅ Each tool is isolated in its own virtual environment
✅ No dependency conflicts with your projects
✅ Easy to update or remove
✅ Cleaner than using `pip install --user`

---

👉 With `pipx`, you can keep your Python environment **tidy** and still enjoy global access to your favorite developer tools.

---

