#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail

echo "🚀 Starting installation of Docker, Kind, and kubectl..."

# ----------------------------
# 1. Install Docker (latest official)
# ----------------------------
if ! command -v docker &>/dev/null; then
  echo "📦 Installing latest Docker from official repository..."
  
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg lsb-release

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "👤 Adding current user to docker group..."
  sudo usermod -aG docker "$USER"

  echo "✅ Docker (latest stable) installed successfully."
else
  echo "✅ Docker is already installed."
fi

# ----------------------------
# 2. Install Kind (latest release)
# ----------------------------
if ! command -v kind &>/dev/null; then
  echo "📦 Installing latest Kind..."

  KIND_VERSION=$(curl -Ls https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep tag_name | cut -d '"' -f 4)
  ARCH=$(uname -m)
  
  case "$ARCH" in
    x86_64)  KIND_ARCH="amd64" ;;
    aarch64) KIND_ARCH="arm64" ;;
    *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
  esac

  curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${KIND_ARCH}"
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind

  echo "✅ Kind ${KIND_VERSION} installed successfully."
else
  echo "✅ Kind is already installed."
fi

# ----------------------------
# 3. Install kubectl (latest stable)
# ----------------------------
if ! command -v kubectl &>/dev/null; then
  echo "📦 Installing kubectl (latest stable version)..."
  
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)  KUBE_ARCH="amd64" ;;
    aarch64) KUBE_ARCH="arm64" ;;
    *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
  esac

  KUBE_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
  curl -LO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubectl"
  
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl

  echo "✅ kubectl ${KUBE_VERSION} installed successfully."
else
  echo "✅ kubectl is already installed."
fi

# ----------------------------
# 4. Confirm Versions
# ----------------------------
echo
echo "🔍 Installed Versions:"
docker --version
kind --version
kubectl version --client --output=yaml

echo
echo "🎉 Docker, Kind, and kubectl installation complete!"
echo "👉 Please log out and back in (or run 'newgrp docker') to use Docker without sudo."
