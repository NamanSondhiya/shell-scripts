# Configure the Yarn APT repository
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Update package index
sudo apt update

# Install Yarn (without Node.js to avoid conflicts)
sudo apt install --no-install-recommends yarn

# Verify Yarn installation
yarn --version
