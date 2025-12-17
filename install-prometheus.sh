#!/bin/bash
set -e

PROMETHEUS_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+' )

wget -qO- https://github.com/prometheus/prometheus/releases/latest/download/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz | tar -xz -C /tmp
sudo cp /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo cp /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/
sudo cp -r /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus
sudo cp -r /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus

sudo bash -c 'cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=nobody
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

NODE_EXPORTER_VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+' )
wget -qO- https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz | tar -xz
sudo cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/

sudo bash -c 'cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

BLACKBOX_VERSION=$(curl -s https://api.github.com/repos/prometheus/blackbox_exporter/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+' )
wget -qO- https://github.com/prometheus/blackbox_exporter/releases/latest/download/blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz | tar -xz
sudo cp blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64/blackbox_exporter /usr/local/bin/

sudo bash -c 'cat > /etc/systemd/system/blackbox_exporter.service <<EOF
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nobody
ExecStart=/usr/local/bin/blackbox_exporter

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable --now blackbox_exporter

echo "Prometheus, Node Exporter, and Blackbox Exporter installed and running."

