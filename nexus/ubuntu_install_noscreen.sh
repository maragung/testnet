#!/bin/bash

# Update and install required packages
echo "Updating package list..."
sudo apt-get update

# Create Nexus directory
mkdir -p $HOME/.nexus/

# Ask for Prover ID and save it
echo 'Enter Prover ID:'
read prover_id
echo $prover_id > $HOME/.nexus/prover-id

# Recheck Prover ID
echo "Rechecking Prover ID:"
cat $HOME/.nexus/prover-id

# Install required packages
echo 'Installing required packages...'
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y
sudo apt install build-essential protobuf-compiler -y

# Install Rust
echo 'Installing Rust...'
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"

# Install Nexus CLI
echo 'Installing Nexus CLI...'
curl https://cli.nexus.xyz/install.sh | sh

# Run Nexus CLI
bash -c "
    echo 'Starting Nexus CLI setup...'
    # Add Nexus CLI commands here if necessary
"

echo "Installation and setup complete. You can now use the Nexus CLI."
