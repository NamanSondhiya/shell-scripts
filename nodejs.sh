# Update your package index
sudo apt update

# Install prerequisites
sudo apt install curl gnupg -y

# Add the NodeSource repository for Node.js 20.x (latest LTS at time of writing)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs

# Verify installation
node -v
npm -v
