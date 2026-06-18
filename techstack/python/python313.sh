#!/bin/bash

set -e

echo "installing python3.13"

sudo apt-get update
sudo apt install -y software-properties-common

sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

sudo apt install -y python3.13 \
python3.13-venv

curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.13

echo "version"
python3.13 --version
pip3.13 --version

echo ""
echo "Python 3.13 installed"
