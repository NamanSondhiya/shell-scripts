sudo apt update

sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key

echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# update 
sudo apt-get update
# install 
sudo apt-get install -y grafana

sudo /bin/systemctl start grafana-server
sudo /bin/systemctl enable grafana-server.service

sudo /bin/systemctl status grafana-server
echo "Installed Succesfully"
