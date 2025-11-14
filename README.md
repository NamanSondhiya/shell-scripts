# Shell Scripts Collection

Hey there! This folder holds a bunch of handy shell scripts I've put together to make setting up common tools on a Linux system a bit easier. These are mostly for Ubuntu/Debian-based setups, and they're designed to automate installations and configurations for things like Docker, monitoring stacks, CI/CD tools, and more. I've tried to keep them straightforward, but always double-check what they're doing before running them—especially if you're on a production machine.

Each script is self-contained, and I'll walk you through what they do, how to use them, and some tips on staying safe while running them. If you're new to this, start with the basics like Docker or Python, and work your way up.

## Prerequisites
Before diving in, make sure your system is up to date and you have sudo access. Most of these scripts assume you're on Ubuntu or a similar Debian-based distro. Run `sudo apt update && sudo apt upgrade` first to keep things smooth.

## Scripts Overview

### 1. docker_compose.sh
**What it does:** Installs Docker and Docker Compose on your machine. It sets up the official Docker repo, installs the engine, and adds the Docker Compose plugin.

**How to use it:**
- Download or copy the script to your machine.
- Make it executable: `chmod +x docker_compose.sh`
- Run it: `./docker_compose.sh`
- After running, log out and back in (or run `newgrp docker`) to use Docker without sudo.

**Notes:** This uses the official Docker install method. It might take a few minutes, and you'll see version confirmations at the end.

**Official Docs:** [Docker Installation Guide](https://docs.docker.com/engine/install/ubuntu/)

### 2. Docker_prometheus_grafana.sh
**What it does:** Sets up Prometheus and Grafana using Docker Compose. It creates a local directory, generates a basic Prometheus config, and spins up containers for both tools.

**How to use it:**
- Make sure Docker and Compose are installed (see docker_compose.sh above).
- Run: `./Docker_prometheus_grafana.sh`
- Access Prometheus at http://localhost:9090 and Grafana at http://localhost:3000 (default login: admin/admin).

**Notes:** Everything runs in containers, so it's easy to tear down with `docker-compose down`. The config is minimal—tweak prometheus.yml if you need more scrapers.

**Official Docs:** [Prometheus Docs](https://prometheus.io/docs/), [Grafana Docs](https://grafana.com/docs/)

### 3. grafana.sh
**What it does:** Installs Grafana directly on the host (not in a container). Adds the official Grafana repo and sets up the service.

**How to use it:**
- Run: `./grafana.sh`
- It updates packages, adds keys, and starts the Grafana service.
- Access at http://localhost:3000 (default login: admin/admin).

**Notes:** This is a host install, so it's persistent across reboots. Check the status with `sudo systemctl status grafana-server`.

**Official Docs:** [Grafana Installation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/)

### 4. jenkins.sh
**What it does:** Installs Jenkins CI/CD server on the host. Includes OpenJDK 21, adds the Jenkins repo, and configures the service.

**How to use it:**
- Run: `./jenkins.sh`
- It installs Java, Jenkins, and opens port 8080 in the firewall if UFW is active.
- Grab the initial admin password from the output or `/var/lib/jenkins/secrets/initialAdminPassword`.
- Access at http://your-server-ip:8080.

**Notes:** First-time setup will guide you through plugins and admin setup. If you're behind a firewall, make sure port 8080 is open.

**Official Docs:** [Jenkins Installation](https://www.jenkins.io/doc/book/installing/linux/)

### 5. microk8s_multipass.sh
**What it does:** Sets up a MicroK8s Kubernetes cluster with Multipass VMs as worker nodes. Installs MicroK8s, enables addons, and launches two worker VMs.

**How to use it:**
- Ensure Snap is installed (it's usually there on Ubuntu).
- Run: `./microk8s_multipass.sh`
- Follow the manual steps at the end to join the workers: Run the join commands in Multipass exec.
- Check nodes with `microk8s kubectl get nodes`.

**Notes:** This creates a multi-node cluster. Taint the control plane to avoid scheduling workloads on it. Multipass VMs use about 2GB RAM each, so plan your resources.

**Official Docs:** [MicroK8s Docs](https://microk8s.io/docs), [Multipass Docs](https://multipass.run/docs)

### 6. prometheus_grafana.sh
**What it does:** Installs Prometheus and Grafana directly on the host. Downloads binaries, sets up systemd services, and configures basic monitoring.

**How to use it:**
- Run: `./prometheus_grafana.sh`
- It installs Prometheus v2.52.0 and Grafana.
- Access Prometheus at http://localhost:9090 and Grafana at http://localhost:3000.

**Notes:** Host installs mean they're managed by systemd. Update versions in the script if you want newer ones. Prometheus config is basic—expand it for real monitoring.

**Official Docs:** [Prometheus Installation](https://prometheus.io/docs/prometheus/latest/installation/), [Grafana Installation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/)

### 7. python.sh
**What it does:** Installs a specific Python version (default 3.11) from the deadsnakes PPA without messing with the system's default Python.

**How to use it:**
- Run: `./python.sh`
- It adds the PPA, installs Python 3.11 and related tools.
- Use it with `python3.11` or set up virtual environments.

**Notes:** Great for isolating Python projects. Change PY_VERSION in the script if you need a different version.

**Official Docs:** [Python Downloads](https://www.python.org/downloads/), [Deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa)

### 8. trivy.sh
**What it does:** Installs Trivy, a vulnerability scanner for containers and filesystems. Adds the Aqua Security repo and installs the tool.

**How to use it:**
- Run: `./trivy.sh`
- After install, scan something like `trivy image ubuntu:latest`.

**Notes:** Trivy is lightweight and fast. Use it to check for vulnerabilities before deploying containers.

**Official Docs:** [Trivy Docs](https://aquasecurity.github.io/trivy/)

## Security Practices
Running scripts from the internet can be risky, so here's how I try to stay safe:

- **Review the code:** Before running any script, open it up and read through it. Make sure it's not doing anything weird like downloading from untrusted sources or running commands as root unnecessarily.
- **Run as non-root when possible:** These scripts use sudo for installs, but test them in a VM first if you're unsure.
- **Check sources:** All these scripts pull from official repos (like Docker, Jenkins, etc.). If a script downloads from GitHub or elsewhere, verify the URL.
- **Firewall and permissions:** Scripts like jenkins.sh open ports—make sure your firewall rules are tight. Don't run as root unless required.
- **Updates and patches:** Keep your system updated. These scripts update packages, but run `sudo apt update` regularly.
- **Isolate experiments:** Use VMs or containers for testing. If something goes wrong, it's easier to wipe and start over.
- **Backups:** Before major changes, back up important configs. Tools like these can overwrite files.
- **Least privilege:** After setup, run services as dedicated users (like Jenkins does). Avoid running everything as root.

If you're sharing these or running them on shared systems, get a second pair of eyes on the scripts. Better safe than sorry!

## Troubleshooting
- If a script fails, check the error messages—often it's a missing dependency or network issue.
- For Docker issues, try `sudo systemctl status docker`.
- Kubernetes stuff? Use `microk8s status` or `kubectl get pods`.
- Always check logs: `journalctl -u service-name` for systemd services.

If you run into problems or have suggestions, feel free to tweak the scripts. Happy automating!
