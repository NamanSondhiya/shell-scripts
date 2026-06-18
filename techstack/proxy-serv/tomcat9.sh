#!/bin/bash

set -e

echo "installing tomcat9"

sudo apt-get update
sudo apt-get install -y tomcat9 tomcat9-admin

sudo systemctl enable tomcat9
sudo systemctl start tomcat9

echo "status"
sudo systemctl status tomcat9 --no-pager

echo ""
echo "installed tomcat9"
