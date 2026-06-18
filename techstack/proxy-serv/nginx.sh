#!/bin/bash

set -e

echo "installing nginx"

sudo apt-get update
sudo apt-get install -y nginx

sudo systemctl enable nginx
sudo systemctl start nginx

echo "version:"
nginx -v

echo "status"
sudo systemctl status nginx --no-pager

echo ""
echo "installed nginx"
