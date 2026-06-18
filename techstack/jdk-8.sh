#!/bin/bash

set -e

echo "installing jdk8"

sudo apt-get update
sudo apt install -y openjdk-8-jdk

echo "configuring JAVA_HOME.."

cat <<EQF | sudo tee /etc/profile.d/java8.sh >/dev/null
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=\$JAVA_HOME/bin:\$PATH
EQF

source /etc/profile.d/java8.sh

echo "validation"
java -version
javac -version

echo "Jdk-8 is installed"


