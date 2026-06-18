#!/bin/bash

set -e

echo "start fix from startup.sh to catalina.sh"

sudo tee /etc/systemd/system/tomcat9.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=exec
User=tomcat9
Group=tomcat9
Environment="JAVA_HOME=/usr/lib/jvm/temurin-8-amd64"
Environment="CATALINA_HOME=/opt/tomcat9"
ExecStart=/opt/tomcat9/bin/catalina.sh run
ExecStop=/opt/tomcat9/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start tomcat9
sudo systemctl status tomcat9 --no-pager
