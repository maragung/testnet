#!/bin/bash

# Function to install Docker and Docker Compose
install_docker_and_docker_compose() {
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose installation failed. Exiting."
        exit 1
    fi

    echo "Docker and Docker Compose installation complete."
}

# Function to set up Docker Compose
setup_docker_compose() {
    echo "Setting up Docker Compose..."
    DOCKER_COMPOSE_FILE_URL="https://raw.githubusercontent.com/chainwayxyz/citrea/v0.4.0/docker-compose.yml"
    DOCKER_COMPOSE_FILE="docker-compose.yml"

    curl -L $DOCKER_COMPOSE_FILE_URL -o $DOCKER_COMPOSE_FILE

    if [ $? -ne 0 ]; then
        echo "Failed to download docker-compose.yml. Exiting."
        exit 1
    fi

    # Set default value for ROLLUP__STORAGE__DB_MAX_OPEN_FILES if not set
    export ROLLUP__STORAGE__DB_MAX_OPEN_FILES=${ROLLUP__STORAGE__DB_MAX_OPEN_FILES:-100}

    # Set ROLLUP__RUNNER__INCLUDE_TX_BODY to false if not needed
    export ROLLUP__RUNNER__INCLUDE_TX_BODY=${ROLLUP__RUNNER__INCLUDE_TX_BODY:-true}

    echo "Running Docker Compose..."
    docker-compose up -d

    if [ $? -ne 0 ]; then
        echo "Failed to run Docker Compose. Exiting."
        exit 1
    fi

    echo "Docker Compose setup complete. The node is syncing with the network."
}

# Function to restart Docker Compose
restart_docker_compose() {
    echo "Restarting Docker Compose..."
    docker-compose down
    docker-compose up -d
    echo "Docker Compose restarted."
}

# Function to read Docker Compose logs
read_docker_logs() {
    echo "Reading Docker Compose logs..."
    docker-compose logs -f
}

# Function to uninstall Docker and clean up
uninstall_docker() {
    echo "Stopping Docker Compose..."
    docker-compose down

    echo "Uninstalling Docker..."
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
    sudo apt-get autoremove -y --purge docker-ce docker-ce-cli containerd.io
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/docker
    sudo rm -rf /etc/apt/keyrings/docker.gpg
    sudo rm /etc/apt/sources.list.d/docker.list
    sudo rm -rf /usr/local/bin/docker-compose

    echo "Docker and Docker Compose have been uninstalled."
}

# Main menu
echo "Select an option:"
echo "1. Install Docker and Docker Compose"
echo "2. Set up Docker Compose"
echo "3. Restart Docker Compose"
echo "4. Read logs"
echo "5. Uninstall Docker and Docker Compose"
read -p "Enter your choice [1-5]: " choice

case $choice in
    1)
        install_docker_and_docker_compose
        setup_docker_compose
        ;;
    2)
        setup_docker_compose
        ;;
    3)
        restart_docker_compose
        ;;
    4)
        read_docker_logs
        ;;
    5)
        uninstall_docker
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac
