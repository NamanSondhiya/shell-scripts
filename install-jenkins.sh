#!/bin/bash
set -e
echo "Jenkins Installation Script (Ubuntu/Debian)"
sudo apt update && sudo apt upgrade -y

# Installing Jenkins Dependency 
echo "Installing OpenJDK 21..."
sudo apt install -y openjdk-21-jdk
java -version

# Installing Jenkins
echo "Adding Jenkins GPG key (2023)..."
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

if command -v ufw > /dev/null; then
    echo "Configuring UFW to allow Jenkins on port 8080..."
    sudo ufw allow 8080
    sudo ufw reload
else
    echo "UFW firewall not found; skipping firewall configuration."
fi

sudo systemctl status jenkins | grep -i Active
echo "Fetching Jenkins initial admin password..."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "---- Jenkins installation completed successfully ----"
echo "Access Jenkins at: http://<your-server-ip>:8080"
echo "Use the above password to unlock Jenkins during first-time setup."
