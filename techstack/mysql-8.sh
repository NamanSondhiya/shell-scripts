#!/bin/bash

set -e

echo "installing mysql8.."


sudo apt-get update
sudo apt install -y mysql-server mysql-client

sudo systemctl enable mysql
sudo systemctl start mysql

echo "mysql stat"
sudo systemctl status mysql --no-pager

echo "Version:"
mysql --version

echo ""
echo "Run manually:"
echo "sudo mysql_secure_installation"


