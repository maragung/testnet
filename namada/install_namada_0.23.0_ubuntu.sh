#!/bin/bash

echo -e "\033[32m"
cat << "EOF"
                  _                         _            
  __   __    ____ (_)__  ____   ____  _   _ (_)__    ____ 
 (__)_(__)  (____)(____)(____) (____)(_) (_)(____)  (____)
(_) (_) (_)( )_( )(_)  ( )_( )( )_(_)(_)_(_)(_) (_)( )_(_)
(_) (_) (_) (__)_)(_)   (__)_) (____) (___) (_) (_) (____)
                              (_)_(_)              (_)_(_)
                               (___)                (___)
EOF
echo -e "\033[0m"

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get install curl wget jq screen

# Download and install libssl1.1 package
echo "Downloading and installing libssl1.1 package..."
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# Download and extract cometbft application
echo "Downloading and extracting cometbft application..."
wget https://github.com/cometbft/cometbft/releases/download/v0.37.2/cometbft_0.37.2_linux_amd64.tar.gz
tar xvzf cometbft_0.37.2_linux_amd64.tar.gz
sudo cp ./cometbft /usr/local/bin/
chmod +x /usr/local/bin/cometbft

# Download and extract namada application
echo "Downloading and extracting namada v0.23.0 application..."
wget https://github.com/anoma/namada/releases/download/v0.23.0/namada-v0.23.0-Linux-x86_64.tar.gz
tar xvzf namada-v0.23.0-Linux-x86_64.tar.gz
cd namada-v0.23.0-Linux-x86_64
sudo cp ./namada* /usr/local/bin/

# Clean up downloaded files (optional)
echo "Cleaning up downloaded files (optional)..."
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb cometbft_0.37.2_linux_amd64.tar.gz namada-v0.23.0-Linux-x86_64.tar.gz

echo "Installation completed."
