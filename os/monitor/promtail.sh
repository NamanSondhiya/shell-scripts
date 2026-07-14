#!/usr/bin/env bash
set -euo pipefail

# SERVER="${1:?usage: $0 <server-label> [loki-url]}"

if [ -n "${1:-}" ]; then
  SERVER="$1"
else
  read -rp "Server label(must match prometheus.yml 'server:' - e.g. elk3 / kafka-waters / lorawan-prod): " SERVER
fi
[ -n "${SERVER:-}" ] || { echo "ERROR: server label required"; exit 1; }

LOKI_URL="${2:-http://68.183.131.47:3100}"
V=3.0.0

cd /tmp
command -v unzip >/dev/null || { sudo apt-get update -q && sudo apt-get install -y unzip; }

wget -q "https://github.com/grafana/loki/releases/download/v${V}/promtail-linux-amd64.zip"
unzip -o -q promtail-linux-amd64.zip

sudo install -m0755 promtail-linux-amd64 /usr/local/bin/promtail
sudo mkdir -p /etc/promtail /var/lib/promtail

sudo tee /etc/promtail/config.yaml >/dev/null <<EQF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: ${LOKI_URL}/loki/api/v1/push

scrape_configs:
  - job_name: syslog
    static_configs:
      - targets: [localhost]
        labels:
          job: syslog
          server: ${SERVER}
          __path__: /var/log/syslog
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 15s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: container
      - source_labels: ['__meta_docker_container_log_stream']
        target_label: stream
      - replacement: '${SERVER}'
        target_label: server
      - replacement: docker
        target_label: job
  # - job_name: kafka-bridge
  #   static_configs:
  #     - targets: [localhost]
  #       labels:
  #         job: kafka-bridge
  #         server: kafka-waters
  #         __path__: /var/log/kafka-bridge.log
    # static_configs:
    #   - targets: [localhost]
    #     labels:
    #       job: docker
    #       server: ${SERVER}
    #       __path__: /var/lib/docker/containers/*/*-json.log
    # pipeline_stages:
    #   - json:
    #       expressions:
    #         log: log
    #         stream: stream
    #   - output:
    #       source:
    #         log
EQF

sudo tee /etc/systemd/system/promtail.service >/dev/null <<'EQF'
[Unit]
Description=Promtail
After=network.target
[Service]
MemoryMax=200M
CPUQuota=50%
User=root
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/config.yaml
Restart=on-failure
[Install]
WantedBy=multi-user.target
EQF

sudo systemctl daemon-reload
sudo systemctl enable promtail
sudo systemctl restart promtail

rm -f /tmp/promtail-linux-amd64.zip /tmp/promtail-linux-amd64

sleep 1

sudo systemctl is-active promtail && echo "OK: promtail --> ${LOKI_URL} as server=${SERVER}"
