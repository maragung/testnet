#!/bin/bash

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}

# Function to setup Bitcoin Signet
setup_bitcoin_signet() {
    echo "Setting up Bitcoin Signet..."
    # Step 1.2: Clone Bitcoin Signet Container
    git clone https://github.com/chainwayxyz/bitcoin_signet && cd bitcoin_signet

    # Step 1.3: Build Signet Container
    docker build -t bitcoin-signet .

    # Step 1.4: Run Signet Container
    docker run -d --name bitcoin-signet-client-instance \
        --env MINERENABLED=0 \
        --env SIGNETCHALLENGE=512102653734c749d5f7227d9576b3305574fd3b0efdeaa64f3d500f121bf235f0a43151ae \
        --env BITCOIN_DATA=/mnt/task/btc-data \
        --env ADDNODE=signet.citrea.xyz:38333 -p 38332:38332 \
        bitcoin-signet
}

# Function to setup Citrea Devnet Client
setup_citrea_devnet() {
    echo "Setting up Citrea Devnet Client..."
    # Step 2.1: Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    # Step 2.2: Clone Citrea repository
    git clone https://github.com/chainwayxyz/citrea --branch=v0.4.5 && cd citrea

    # Step 2.3: Edit rollup config file
    cat <<EOF > configs/devnet/rollup_config.toml
# DA Config
[da]
node_url = "http://0.0.0.0:38332"
node_username = "bitcoin"
node_password = "bitcoin"
network = "signet"

# Full Node RPC
[rpc]
bind_host = "127.0.0.1"
bind_port = 12345

[runner]
sequencer_client_url = "https://rpc.devnet.citrea.xyz"
include_tx_body = false
EOF

    # Step 2.4: Build the project
    SKIP_GUEST_BUILD=1 make build-release

    # Optional: Install dev tools
    # make install-dev-tools

    echo "Citrea Devnet setup completed."
}

# Function to read Docker logs
read_docker_logs() {
    echo "Reading Docker logs..."
    docker-compose logs -f
}

# Function to uninstall Docker
uninstall_docker() {
    echo "Stopping Docker service..."
    sudo systemctl stop docker.service

    echo "Uninstalling Docker..."
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/docker

    echo "Docker and its dependencies have been uninstalled."
}

# Function to run Citrea after setup
run_citrea() {
    echo "Running Citrea..."
    ./target/release/citrea --da-layer bitcoin --rollup-config-path configs/devnet/rollup_config.toml --genesis-paths configs/devnet/genesis-files
}

# Main menu
echo "Select an option:"
echo "1. Install Docker and setup Bitcoin Signet & Citrea Devnet"
echo "2. Read Docker logs"
echo "3. Uninstall Docker"
echo "4. Run Citrea"
echo "5. Exit"
read -p "Enter your choice [1-5]: " choice

case $choice in
    1)
        install_docker
        setup_citrea_devnet
        setup_bitcoin_signet
        ;;
    2)
        read_docker_logs
        ;;
    3)
        uninstall_docker
        ;;
    4)
        run_citrea
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

exit 0

