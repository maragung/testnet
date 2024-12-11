#!/bin/bash

# Update and install required packages
echo "Updating package list..."
sudo apt-get update

echo "Installing screen..."
sudo apt install screen -y

# Create a new screen session named "nexus" and execute commands inside it
screen -S nexus -d -m bash -c "
    echo 'Installing required packages...'
    sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y
    sudo apt install build-essential protobuf-compiler -y

    # Install Rust
    echo 'Installing Rust...'
    sudo curl https://sh.rustup.rs -sSf | sh
    source \$HOME/.cargo/env
    export PATH=\"\$HOME/.cargo/bin:\$PATH\"

    # Create Nexus directory
    mkdir -p \$HOME/.nexus/

    # Ask for Prover ID and save it
    echo 'Enter Prover ID:'
    read prover_id
    echo \$prover_id > \$HOME/.nexus/prover-id

    # Open Prover ID in nano for user to edit and save
    nano \$HOME/.nexus/prover-id

    # Install Nexus CLI
    echo 'Installing Nexus CLI...'
    sudo curl https://cli.nexus.xyz/install.sh | sh

    echo 'Installation complete. You are now in the "nexus" screen session.'
    echo 'You can use "exit" to leave the screen session.'
"

echo "Installation started in the 'nexus' screen session. You can check the progress by attaching to it."
