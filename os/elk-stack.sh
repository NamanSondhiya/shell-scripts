#!/bin/bash

set -e

echo "[INFO] Updating package index..."
sudo apt update -y

echo "[INFO] Installing required packages..."
sudo apt install -y \
  openssl \
  python3 \
  unzip

echo "[INFO] Verifying installations..."

echo -n "openssl: "
openssl version || echo "Not installed"

echo -n "python3: "
python3 --version || echo "Not installed"

echo -n "unzip: "
unzip -v | head -n 1 || echo "Not installed"

echo "[INFO] Checking sudo access..."
if sudo -n true 2>/dev/null; then
  echo "sudo: OK (no password required)"
else
  echo "sudo: Available (may require password)"
fi

echo "[INFO] Setup complete."
