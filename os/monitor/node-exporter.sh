#!/usr/bin/env bash
set -euo pipefail
V=1.8.1
cd /tmp
wget -q https://github.com/prometheus/node_exporter/releases/download/v${V}/node_exporter-${V}.linux-amd64.tar.gz
tar xf node_exporter-${V}.linux-amd64.tar.gz
sudo install -m0755 node_exporter-${V}.linux-amd64/node_exporter /usr/local/bin/node_exporter
sudo useradd -rs /bin/false node_exporter 2>/dev/null || true
sudo tee /etc/systemd/system/node_exporter.service >/dev/null <<'EOF'
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
rm -rf /tmp/node_exporter-${V}.linux-amd64*
echo "OK: $(curl -s localhost:9100/metrics | head -1)"
