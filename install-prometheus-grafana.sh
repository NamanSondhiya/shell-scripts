#!/bin/bash

# Exit on error
set -e

echo "---- Installing Prometheus & Grafana (Host Installation) ----"

# Update packages
sudo apt update

# Install dependencies
sudo apt install -y wget curl gnupg apt-transport-https software-properties-common

# ----------------------------
# Install Prometheus
# ----------------------------

PROM_VERSION="2.52.0"  # You can change to latest

echo "Installing Prometheus v$PROM_VERSION..."

# Create Prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create directories
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Download and extract
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

cd prometheus-${PROM_VERSION}.linux-amd64
sudo cp prometheus promtool /usr/local/bin/
sudo cp -r consoles console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus/

# Set ownership
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/ \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Start Prometheus
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

# ----------------------------
# Install Grafana
# ----------------------------

echo "Installing Grafana..."

# Add Grafana repo and key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | \
  sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null

# Install Grafana
sudo apt update
sudo apt install -y grafana

# Enable and start Grafana
sudo systemctl enable --now grafana-server

# ----------------------------
# Done
# ----------------------------

echo "---- Installation Complete ----"
echo "Prometheus: http://localhost:9090"
echo "Grafana:    http://localhost:3000 (Login: admin / admin)"
