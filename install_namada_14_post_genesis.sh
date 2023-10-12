#!/bin/bash

# Variables
WALLET_ALIAS=""
VALIDATOR_ALIAS=""
CHAIN_ID="public-testnet-14.5d79b6958580"

# Prompt the user to input WALLET_ALIAS
read -p "Enter your wallet alias: " WALLET_ALIAS

# Prompt the user to input VALIDATOR_ALIAS
read -p "Enter your validator alias: " VALIDATOR_ALIAS

# Export the input values as environment variables
export WALLET_ALIAS="$WALLET_ALIAS"
export VALIDATOR_ALIAS="$VALIDATOR_ALIAS"

# Append export commands to ~/.bash_profile
echo "export WALLET_ALIAS=\"$WALLET_ALIAS\"" >> ~/.bash_profile
echo "export VALIDATOR_ALIAS=\"$VALIDATOR_ALIAS\"" >> ~/.bash_profile

echo "Wallet alias set to: $WALLET_ALIAS"
echo "Validator alias set to: $VALIDATOR_ALIAS"

# Rest of the script...

echo -e 'Setting up swapfile...\n'
curl -s https://raw.githubusercontent.com/maragung/testnet/main/add_swap_area.sh | bash
echo 'source $HOME/.bashrc' >> $HOME/.bash_profile

# Update and install basic apps
echo "Updating and installing basic apps..."
sudo apt-get update
sudo apt-get install curl wget jq screen -y

# Install libssl1.1 package
echo "Installing libssl1.1 package..."
wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb

# Download and extract cometbft application
echo "Downloading and extracting cometbft application..."
wget https://github.com/cometbft/cometbft/releases/download/v0.37.2/cometbft_0.37.2_linux_amd64.tar.gz
tar xvzf cometbft_0.37.2_linux_amd64.tar.gz

echo "Copying cometbft to /usr/local/bin..."
sudo cp ./cometbft /usr/local/bin/
chmod +x /usr/local/bin/cometbft

# Download and extract namada application
echo "Downloading and extracting namada application..."
wget https://github.com/anoma/namada/releases/download/v0.23.0/namada-v0.23.0-Linux-x86_64.tar.gz
tar xvzf namada-v0.23.0-Linux-x86_64.tar.gz
cd namada-v0.23.0-Linux-x86_64

echo "Copying namada to /usr/local/bin..."
sudo cp ./namada* /usr/local/bin/

# Downloading chain-id config
echo "Downloading chain-id config..."
namada client utils join-network --chain-id "$CHAIN_ID"

# Get the path of namada binary using which command
namada_path=$(which namada)

# Create a systemd service for namada
echo "Creating systemd service for namada..."
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$(pwd)
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=$namada_path node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo "Enabling and starting the namada service..."
sudo systemctl daemon-reload
sudo systemctl enable namadad
sudo systemctl start namadad

# Remove downloaded files
echo "Removing downloaded files..."
rm -rf libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb \
  cometbft_0.37.2_linux_amd64.tar.gz namada-v0.23.0-Linux-x86_64.tar.gz

echo "Installation and service setup completed. Downloaded files removed."
