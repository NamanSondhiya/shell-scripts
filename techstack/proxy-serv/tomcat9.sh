#!/bin/bash

set -e

echo ""
echo "Select Tomcat install method:"
echo "  1) tomcat9  — apt (Ubuntu 22.04 only)"
echo "  2) tomcat9  — manual from Apache archive (Ubuntu 24.04+)"
echo "  3) tomcat10 — apt (Ubuntu 24.04, breaks javax.* WARs)"
echo ""
read -rp "Choice [1/2/3]: " CHOICE

case "$CHOICE" in

  1)
    echo "installing tomcat9 via apt.."
    sudo apt-get update
    sudo apt-get install -y tomcat9 tomcat9-admin
    sudo systemctl enable tomcat9
    sudo systemctl start tomcat9
    sudo systemctl status tomcat9 --no-pager
    echo "tomcat9 (apt) installed"
    ;;

  2)
    echo "installing tomcat9 manually.."
    TOMCAT_VERSION=9.0.105
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
    INSTALL_DIR=/opt/tomcat9

    sudo apt-get install -y curl
    curl -fsSL "$TOMCAT_URL" -o /tmp/tomcat9.tar.gz
    sudo mkdir -p "$INSTALL_DIR"
    sudo tar -xzf /tmp/tomcat9.tar.gz -C "$INSTALL_DIR" --strip-components=1
    sudo chmod +x "$INSTALL_DIR"/bin/*.sh
    sudo useradd -r -m -U -d "$INSTALL_DIR" -s /bin/false tomcat9 2>/dev/null || true
    sudo chown -R tomcat9:tomcat9 "$INSTALL_DIR"

    cat <<EOF | sudo tee /etc/systemd/system/tomcat9.service > /dev/null
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat9
Group=tomcat9
Environment="JAVA_HOME=/usr/lib/jvm/temurin-8-amd64"
Environment="CATALINA_HOME=${INSTALL_DIR}"
ExecStart=${INSTALL_DIR}/bin/startup.sh
ExecStop=${INSTALL_DIR}/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable tomcat9
    sudo systemctl start tomcat9
    sudo systemctl status tomcat9 --no-pager
    echo "tomcat9 (manual) installed at ${INSTALL_DIR}"
    ;;

  3)
    echo "installing tomcat10 via apt.."
    sudo apt-get update
    sudo apt-get install -y tomcat10 tomcat10-admin
    sudo systemctl enable tomcat10
    sudo systemctl start tomcat10
    sudo systemctl status tomcat10 --no-pager
    echo "tomcat10 (apt) installed"
    ;;

  *)
    echo "invalid choice. exiting."
    exit 1
    ;;

esac
