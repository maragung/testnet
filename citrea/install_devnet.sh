#!/bin/bash

# Function to install Docker
install_docker() {
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

    echo "Starting Docker service..."
    sudo systemctl enable docker
    sudo systemctl start docker

    # Adding user to Docker group
    echo "Adding user to Docker group..."
    sudo usermod -aG docker $USER
    newgrp docker

    echo "Docker installation complete. Please log out and log back in for the group changes to take effect."
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
echo "1. Install Docker"
echo "2. Set up Docker Compose"
echo "3. Restart Docker"
echo "4. Read logs"
echo "5. Uninstall"
read -p "Enter your choice [1-5]: " choice

case $choice in
    1)
        install_docker
        ;;
    2)
        if ! command -v docker-compose &> /dev/null; then
            echo "Docker Compose not found. Please install Docker Compose first."
            exit 1
        fi
        setup_docker_compose
        ;;
    3)
        if ! command -v docker-compose &> /dev/null; then
            echo "Docker Compose not found. Please install Docker Compose first."
            exit 1
        fi
        restart_docker_compose
        ;;
    4)
        if ! command -v docker-compose &> /dev/null; then
            echo "Docker Compose not found. Please install Docker Compose first."
            exit 1
        fi
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
