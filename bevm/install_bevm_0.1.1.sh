#!/bin/bash

read -p "Enter the address (METAMASK ADDRESS): " user_address

# Check if user_address is provided
if [ -z "$user_address" ]; then
  echo "Address cannot be empty. Please try again."
  exit 1
fi

# Get the full path of the current directory
wget -O bevm https://github.com/btclayer2/BEVM/releases/download/testnet-v0.1.1/bevm-v0.1.1-ubuntu20.04
wait
chmod +x bevm
current_directory=$(pwd)

# Create the systemd service file
cat <<EOF > /etc/systemd/system/bevm.service
[Unit]
Description=BEVM Service
After=network.target

[Service]
ExecStart=$current_directory/bevm --chain=testnet --name="$user_address" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
Restart=always
User=nobody
Group=nogroup

[Install]
WantedBy=default.target
EOF

# Reload systemd manager configuration
systemctl daemon-reload

# Start and enable the service at boot
systemctl start bevm
systemctl enable bevm

echo "BEVM service has been successfully created with the address $user_address."
