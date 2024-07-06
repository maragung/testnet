#!/bin/bash

# Function to install Docker and set up Docker Compose
install_docker_compose() {
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
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    echo "Setting up Docker Compose..."
    DOCKER_COMPOSE_FILE_URL="https://raw.githubusercontent.com/chainwayxyz/citrea/v0.4.0/docker-compose.yml"
    DOCKER_COMPOSE_FILE="docker-compose.yml"

    curl -L $DOCKER_COMPOSE_FILE_URL -o $DOCKER_COMPOSE_FILE

    if [ $? -ne 0 ]; then
        echo "Failed to download docker-compose.yml. Exiting."
        exit 1
    fi

    sed -i 's/ROLLUP__RUNNER__INCLUDE_TX_BODY=true/ROLLUP__RUNNER__INCLUDE_TX_BODY=false/' $DOCKER_COMPOSE_FILE

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
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo apt-get autoremove -y --purge docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/docker
    sudo rm -rf /etc/apt/keyrings/docker.gpg
    sudo rm /etc/apt/sources.list.d/docker.list
    sudo rm -rf /usr/bin/docker-compose

    echo "Docker and Docker Compose have been uninstalled."
}

# Main menu
echo "Select an option:"
echo "1. Install using Docker"
echo "2. Restart Docker"
echo "3. Read logs"
echo "4. Uninstall"
read -p "Enter your choice [1-4]: " choice

case $choice in
    1)
        install_docker_compose
        ;;
    2)
        restart_docker_compose
        ;;
    3)
        read_docker_logs
        ;;
    4)
        uninstall_docker
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac
