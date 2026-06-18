#!/bin/bash

set -e

VENV_NAME=venv

python3.13 -m venv $VENV_NAME

source $VENV_NAME/bin/activate

python --version
pip --version

echo ""
echo "Venv created:"
echo "$VENV_NAME"

