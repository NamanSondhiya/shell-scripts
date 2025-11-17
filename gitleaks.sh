#!/bin/bash
set -e

# Fetch the latest Gitleaks version tag from GitHub
GITLEAKS_VERSION=$(curl -s "https://api.github.com/repos/gitleaks/gitleaks/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+' )

# Download the binary release for linux amd64
wget -qO gitleaks.tar.gz https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz

# Extract the tarball directly to /usr/local/bin
sudo tar xf gitleaks.tar.gz -C /usr/local/bin gitleaks

# Make sure the binary is executable
sudo chmod +x /usr/local/bin/gitleaks

# Clean up the tarball
rm -rf gitleaks.tar.gz

# Verify installation
gitleaks version

