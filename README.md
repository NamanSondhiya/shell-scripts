# Shell Scripts Shenanigans 🛠️

Yo, welcome to my little corner of automation magic! This repo is packed with bash scripts to supercharge your Linux setup (mostly Ubuntu/Debian vibes). From Docker to Kubernetes, monitoring stacks to dev tools—I've got you covered. These bad boys automate installs and configs, but hey, peek under the hood before running 'em, especially on prod machines. They're self-contained, so grab what you need and let's get hacking!

New to this? Kick off with Docker or Python basics. Pro tip: Always `sudo apt update && sudo apt upgrade` before jumping in.

## Quick Start: Running These Scripts
These scripts are plain text files, so they won't run right out of the box—they need execute permissions first. If you're new to this, here's how to make 'em runnable:

1. Open your terminal in this directory.
2. Make the script executable: `chmod +x script-name.sh`
3. Run it: `./script-name.sh`

Example for installing Docker:
```
chmod +x install-docker-n-compose.sh
./install-docker-n-compose.sh
```

Boom! Now you're set. Most scripts will handle the rest, but always check the output for any manual steps.

## The Script Squad

### Docker & Compose
- **install-docker-n-compose.sh**: Slaps on Docker Engine + Compose plugin from official repos. Adds you to the docker group—logout/login or `newgrp docker` to rock without sudo.
  - Run: `chmod +x install-docker-n-compose.sh && ./install-docker-n-compose.sh`
  - Docs: [Docker Install](https://docs.docker.com/engine/install/ubuntu/)

### Monitoring Madness
- **install-prometheus.sh**: Drops Prometheus, Node Exporter, and Blackbox Exporter on your host. Sets up systemd services for auto-start.
  - Run: `./install-prometheus.sh`
  - Access: Prometheus at :9090, exporters running in background.
  - Docs: [Prometheus](https://prometheus.io/docs/prometheus/latest/installation/)
- **install-grafana.sh**: Installs Grafana OSS on host via apt repo. Starts the service—login with admin/admin.
  - Run: `./install-grafana.sh`
  - Access: :3000
  - Docs: [Grafana](https://grafana.com/docs/grafana/latest/setup-grafana/installation/)
- **install-prometheus-grafana.sh**: Host install for both Prometheus (v2.52.0) and Grafana. Systemd-managed, basic config.
  - Run: `./install-prometheus-grafana.sh`
  - Access: Prometheus :9090, Grafana :3000
  - Docs: Same as above—update versions if you're feeling fresh!
- **Docker_prometheus_grafana.sh**: Containerized setup with Docker Compose. Creates ~/prometheus_grafana dir, basic Prometheus config, spins up containers.
  - Run: `./Docker_prometheus_grafana.sh` (needs Docker first)
  - Access: Same ports, tear down with `docker-compose down`
  - Docs: [Prometheus](https://prometheus.io/docs/), [Grafana](https://grafana.com/docs/)

### CI/CD & Security
- **install-jenkins.sh**: Installs Jenkins with OpenJDK 21, sets up service, opens port 8080 in UFW if active.
  - Run: `./install-jenkins.sh`
  - Access: :8080, grab initial password from output or /var/lib/jenkins/secrets/initialAdminPassword
  - Docs: [Jenkins](https://www.jenkins.io/doc/book/installing/linux/)
- **install-trivy.sh**: Vulnerability scanner from Aqua Security. Scans containers/images/filesystems.
  - Run: `./install-trivy.sh`
  - Use: `trivy image ubuntu:latest`
  - Docs: [Trivy](https://aquasecurity.github.io/trivy/)
- **install-gitleaks.sh**: Secret scanner for Git repos. Grabs latest release, installs binary.
  - Run: `./install-gitleaks.sh`
  - Use: `gitleaks --help`
  - Docs: [Gitleaks](https://github.com/gitleaks/gitleaks)

### Kubernetes Fun (in k8s/)
- **microk8s_multipass.sh**: Sets up MicroK8s cluster with Multipass VMs as workers. Enables DNS/storage, launches 2 workers.
  - Run: `./k8s/microk8s_multipass.sh`
  - Manual join: Follow output commands to attach workers.
  - Docs: [MicroK8s](https://microk8s.io/docs), [Multipass](https://multipass.run/docs)
- **kind/kind.sh**: Installs Docker, Kind, and kubectl. Latest versions, adds user to docker group.
  - Run: `./k8s/kind/kind.sh`
  - Docs: [Kind](https://kind.sigs.k8s.io/), [kubectl](https://kubernetes.io/docs/tasks/tools/)

### Tech Stack Staples (in techstack/)
- **nodejs.sh**: Node.js 20.x LTS from NodeSource repo.
  - Run: `./techstack/nodejs.sh`
  - Docs: [Node.js](https://nodejs.org/en/download/)
- **python.sh**: Python 3.11 (default) from deadsnakes PPA, no system breakage.
  - Run: `./techstack/python.sh`
  - Use: `python3.11 --version`
  - Docs: [Python](https://www.python.org/downloads/), [Deadsnakes](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa)
- **yarn.sh**: Yarn package manager (no Node.js conflicts).
  - Run: `./techstack/yarn.sh`
  - Docs: [Yarn](https://yarnpkg.com/getting-started/install)

## Stay Safe, Script Kiddie! 🔒
Scripts can be sneaky—review 'em first. They use official sources, but test in a VM. Backups are your BFF. Run as non-root where possible, and keep your firewall locked down. If ports open (like Jenkins), double-check UFW.

## Oops, Need Help? 🆘
Script fails? Check errors—missing deps or net issues. Docker woes? `sudo systemctl status docker`. K8s? `microk8s status`. Logs: `journalctl -u service-name`.

## Contribute or Update? 🤝
I might forget to bump versions—feel free to update 'em yourself or fork and PR! These scripts auto-fetch latest where possible, but if not, tweak away. Got ideas? Open an issue or send a PR. Let's make this repo even awesomer!

Happy scripting, you magnificent dev!
