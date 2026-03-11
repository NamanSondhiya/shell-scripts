#!/bin/bash

# Exit on error
set -e

echo "---- Setting up Prometheus + Grafana using Docker Compose ----"

# Directory for deployment
WORKDIR=~/prometheus_grafana
mkdir -p $WORKDIR
cd $WORKDIR

# ----------------------------
# Prometheus Configuration
# ----------------------------

mkdir -p prometheus

cat > prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

# ----------------------------
# Docker Compose File
# ----------------------------

cat > docker-compose.yml <<EOF
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    restart: unless-stopped

  grafana:
    image: grafana/grafana-oss:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    restart: unless-stopped

volumes:
  grafana-data:
EOF

# ----------------------------
# Launch the Stack
# ----------------------------

docker-compose up -d

# ----------------------------
# Done
# ----------------------------

echo "---- Prometheus + Grafana containers started ----"
echo "Prometheus: http://localhost:9090"
echo "Grafana:    http://localhost:3000 (admin / admin)"
