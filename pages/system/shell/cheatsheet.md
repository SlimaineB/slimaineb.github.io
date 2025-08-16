---
layout: page
title: Shell & System Cheat Sheet
nav_order: 2
parent: Shell
permalink: /system/shell/cheatsheet
---

# 🖥️ Shell & System Cheat Sheet

## 🚀 Basic Commands

{% highlight bash %}
# File system
ls -lah                   # List files with details
cd /path/to/dir           # Change directory
pwd                       # Print current directory
mkdir -p /path/to/dir     # Create directory recursively
rm -rf /path/to/dir       # Delete directory recursively

# File operations
cp source dest            # Copy file
mv source dest            # Move/rename file
cat file                  # Show file content
less file                 # Paginated view
head -n 20 file           # Show first 20 lines
tail -n 20 file           # Show last 20 lines
grep "pattern" file       # Search text in files
find /path -name "*.txt"  # Find files by name
stat file                 # File details (size, permissions, timestamps)
file file                 # Identify file type
{% endhighlight %}

---

## 🛠️ Process & System Management

{% highlight bash %}
ps aux                     # List all running processes
top                        # Interactive process monitor
htop                       # Enhanced interactive monitor
kill <pid>                 # Kill process by PID
pkill -f process_name      # Kill process by name
df -h                      # Disk usage
du -sh /path/to/dir        # Folder size
free -h                    # Memory usage
uptime                      # System uptime
whoami                     # Current user
id                         # User and group info
lsof -i :80                # List processes using port 80
systemctl status <service>  # Check service status
journalctl -xe             # View system logs
{% endhighlight %}

---

## 🔄 Networking

{% highlight bash %}
ping google.com              # Check connectivity
curl -I https://example.com  # HTTP headers
wget https://example.com/file.txt  # Download file
netstat -tulnp               # Show listening ports
ss -tuln                     # Modern replacement for netstat
traceroute example.com       # Trace network route
ssh user@host                # SSH into server
scp file user@host:/path     # Copy files over SSH
dig example.com              # DNS lookup
nslookup example.com         # DNS lookup alternative
iptables -L                  # List firewall rules
{% endhighlight %}

---

## 🧰 Advanced Bash Scripting

{% highlight bash %}
#!/bin/bash
# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Variables and defaults
NAME=${1:-World}             # Default parameter if not provided
ARR=(one two three)
ARR+=("four")

# Loops
for i in "${ARR[@]}"; do
  echo "Item: $i"
done

count=1
while [[ $count -le 5 ]]; do
  echo "Count: $count"
  ((count++))
done

# Functions with defaults and local variables
greet() {
  local name=${1:-Guest}
  echo "Hello, $name!"
}

greet "$NAME"

# Conditionals
if [[ -f /tmp/test.txt ]]; then
  echo "File exists"
elif [[ -d /tmp/testdir ]]; then
  echo "Directory exists"
else
  echo "Nothing found"
fi

case "$NAME" in
  Alice) echo "Hi Alice" ;;
  Bob) echo "Hi Bob" ;;
  *) echo "Hi Stranger" ;;
esac

# Command substitution & pipelines
FILES=$(ls -1 /tmp)
grep "pattern" <(cat "$FILES") | sort | uniq

# Exit status check
if command -v git >/dev/null 2>&1; then
  echo "Git installed"
else
  echo "Git missing"
fi

# Redirections
echo "Message" > log.txt      # stdout to file
echo "Error message" >&2      # stderr
command &> all.log            # stdout + stderr
command | tee output.log      # stdout + console
{% endhighlight %}

---

## ⚡ CI/CD & Non-Interactive Flags

{% highlight bash %}
# Non-interactive apt install
DEBIAN_FRONTEND=noninteractive apt-get install -y package

# Bash in pipelines
set -e       # Exit on first error
set -x       # Debug mode (print commands)
export VAR=value    # Set environment variable for CI/CD
chmod +x script.sh  # Make script executable
./script.sh         # Run script in CI/CD pipeline

# Example: validate dependencies
for tool in git docker terraform; do
  command -v $tool >/dev/null 2>&1 || { echo "$tool not installed"; exit 1; }
done
{% endhighlight %}

---

## 📝 Best Practices

- Use **`set -euo pipefail`** for safe scripts  
- Always **quote variables** (`"$VAR"`)  
- Prefer **functions** for reusable logic  
- Use **trap** for cleanup (`trap 'rm -f temp_file' EXIT`)  
- Validate dependencies (`command -v <tool> || exit 1`)  
- Log messages for CI/CD (`echo "[INFO]..."` or `>&2`)  
- Separate **configuration and logic** (env vars vs code)  
- Prefer **absolute paths** in automation scripts  
- Comment your scripts clearly and structure sections  
- Use **arrays** for handling multiple values safely  
- Avoid using `rm -rf $VAR` without proper checks  

---

This Shell & System cheat sheet complements your **System section**, covering **advanced scripting, process management, networking, CI/CD automation, and best practices**.
