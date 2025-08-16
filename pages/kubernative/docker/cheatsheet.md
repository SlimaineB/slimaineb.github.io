---
layout: page
title: Docker Cheat Sheet
nav_order: 2
parent: Docker
permalink: /kubernative/docker/cheatsheet
---

# ⚡ Advanced Docker Cheat Sheet

## 🚀 Basic Commands

{% highlight bash %}
docker --version                       # Check Docker version
docker info                            # Show Docker system info
docker images                          # List local images
docker ps                              # List running containers
docker ps -a                           # List all containers
docker pull <image>                    # Pull an image from registry
docker run -it --name mycontainer <image>   # Run a container interactively
docker stop <container>                # Stop a running container
docker rm <container>                  # Remove a container
docker rmi <image>                     # Remove an image
{% endhighlight %}

---

## 📦 Image Management

{% highlight bash %}
docker build -t myimage:latest .       # Build image from Dockerfile
docker tag myimage:latest myrepo/myimage:latest
docker push myrepo/myimage:latest      # Push image to registry
docker history <image>                 # Show image history
docker inspect <image|container>       # Detailed info
{% endhighlight %}

---

## 🛠️ Container Management

{% highlight bash %}
docker exec -it <container> bash       # Enter running container
docker logs -f <container>             # Follow logs
docker stats                            # Show resource usage
docker cp <container>:/path /local/path # Copy files from container
docker commit <container> <new_image>   # Save container as new image
docker network ls                       # List networks
docker network inspect <network>        # Inspect network
{% endhighlight %}

---

## 🔄 Volumes & Bind Mounts

{% highlight bash %}
docker volume create myvolume
docker volume ls
docker volume inspect myvolume
docker run -v myvolume:/data <image>   # Use a volume
docker run -v /host/path:/container/path <image>   # Bind mount
{% endhighlight %}

---

## 🔗 Networking

{% highlight bash %}
docker network create mynet             # Create a custom network
docker run --network=mynet <image>      # Connect container to network
docker network connect mynet <container>
docker network disconnect mynet <container>
{% endhighlight %}

---

## 🔍 Debugging & Logs

{% highlight bash %}
docker logs -f <container>              # Stream logs
docker inspect <container>              # Full JSON details
docker top <container>                  # Show processes inside container
docker diff <container>                 # Changes in filesystem
{% endhighlight %}

---

## ⚙️ CI/CD Environment Variables

Useful in pipelines to make Docker non-interactive:

{% highlight bash %}
# Disable Docker interactive prompts
export DOCKER_BUILDKIT=1               # Use BuildKit for faster builds
export COMPOSE_DOCKER_CLI_BUILD=1      # Enable Docker CLI build in CI
export DOCKER_BUILDKIT_PROGRESS=plain  # Plain output for logs
export DOCKER_CLI_HINTS=0              # Disable CLI hints
export DOCKER_HOST=tcp://docker:2375   # Use remote Docker host (if needed)
{% endhighlight %}

---

## ⚡ Useful Flags

- `-d` → Run container in detached mode  
- `--rm` → Automatically remove container after exit  
- `-p <host>:<container>` → Port mapping  
- `-e <VAR>=<value>` → Environment variable in container  
- `--name <name>` → Name your container  
- `--network <network>` → Connect container to custom network  
- `--volume/-v` → Mount volumes or directories  

---

## 📝 Best Practices

- Always use **specific image tags** (`nginx:1.25`)  
- Keep **Dockerfiles small** and multi-stage builds for production  
- Use **.dockerignore** to reduce build context  
- Avoid running containers as root unless necessary  
- Use **volumes** for persistent data, not container filesystem  
- Log output to **stdout/stderr** for CI/CD monitoring  
- Clean up dangling images and stopped containers regularly (`docker system prune`)
