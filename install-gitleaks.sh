#!/bin/bash
set -e

GITLEAKS_VERSION=$(curl -s "https://api.github.com/repos/gitleaks/gitleaks/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+' )

wget -qO gitleaks.tar.gz https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz

sudo tar xf gitleaks.tar.gz -C /usr/local/bin gitleaks

sudo chmod +x /usr/local/bin/gitleaks

rm -rf gitleaks.tar.gz

gitleaks version

