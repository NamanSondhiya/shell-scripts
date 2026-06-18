#!/bin/bash

set -e

echo "installing jdk8"

sudo apt-get update

UBUNTU_VERSION=$(lsb_release -rs)

if [[ "$UBUNTU_VERSION" == "24.04" ]] || [[ "${UBUNTU_VERSION%%.*}" -ge 24 ]]; then
    echo "Ubuntu 24.04+ detected — using Eclipse Temurin for JDK 8"
    sudo mkdir -p /etc/apt/keyrings
	wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
    | sudo tee /etc/apt/keyrings/adoptium.asc > /dev/null
	echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/adoptium.list

    sudo apt-get update
    sudo apt-get install -y temurin-8-jdk
    JAVA_HOME_PATH=/usr/lib/jvm/temurin-8-jdk-amd64
else
    echo "Ubuntu 22.04 or earlier — installing from default repos"
    sudo apt install -y openjdk-8-jdk
    JAVA_HOME_PATH=/usr/lib/jvm/java-8-openjdk-amd64
fi

echo "configuring JAVA_HOME.."

cat <<EQF | sudo tee /etc/profile.d/java8.sh >/dev/null
export JAVA_HOME=${JAVA_HOME_PATH}
export PATH=\$JAVA_HOME/bin:\$PATH
EQF

source /etc/profile.d/java8.sh

echo "validation"
java -version
javac -version

echo "Jdk-8 is installed"


