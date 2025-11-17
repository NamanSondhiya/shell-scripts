#!/bin/bash
# safe_install_python.sh
# Install Python (default: 3.11) without breaking system python3

set -e

PY_VERSION="3.11"

echo "🚀 Updating system packages..."
sudo apt update -y

echo "📦 Installing dependencies..."
sudo apt install -y software-properties-common curl wget build-essential

echo "➕ Adding deadsnakes PPA..."
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y

echo "🐍 Installing Python $PY_VERSION..."
sudo apt install -y python${PY_VERSION} python${PY_VERSION}-venv python${PY_VERSION}-dev python${PY_VERSION}-distutils

echo "✅ Installed versions:"
python${PY_VERSION} --version

