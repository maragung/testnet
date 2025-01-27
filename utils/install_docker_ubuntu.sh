#!/bin/bash

# Ensure the script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Function to install Docker
install_docker() {
  echo "\n[1/7] Updating package list..."
  sudo apt update && sudo apt upgrade -y

  echo "\n[2/7] Installing dependencies..."
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

  echo "\n[3/7] Adding Docker's GPG key..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "\n[4/7] Adding Docker repository..."
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  echo "\n[5/7] Installing Docker and plugins..."
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  echo "\nInstalling additional Docker plugins (if available)..."
  sudo apt install -y docker-buildx-plugin docker-scan-plugin

  echo "\n[6/7] Enabling and starting Docker service..."
  sudo systemctl enable docker
  sudo systemctl start docker

  echo "\nAdding user to 'docker' group..."
  sudo groupadd docker 2>/dev/null || echo "Group 'docker' already exists."
  sudo usermod -aG docker $USER

  echo -e "\nDocker installed successfully with all plugins.\nPlease log out and log back in, or run 'newgrp docker' to use Docker without sudo."
  docker --version && docker compose version && echo "\nTesting 'docker run hello-world':" && docker run hello-world
}

# Function to uninstall Docker
uninstall_docker() {
  echo "\nUninstalling Docker and plugins..."
  sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin docker-scan-plugin
  sudo rm -rf /var/lib/docker /etc/docker
  sudo rm -rf /var/lib/containerd
  sudo rm /usr/share/keyrings/docker-archive-keyring.gpg
  echo "\nDocker and all plugins have been uninstalled."
}

# Function to reinstall Docker
reinstall_docker() {
  echo "\nReinstalling Docker and plugins..."
  uninstall_docker
  install_docker
}

# Menu options
clear
echo "Docker Management Script"
echo "1. Install Docker (with plugins)"
echo "2. Reinstall Docker (with plugins)"
echo "3. Uninstall Docker (and plugins)"
echo "4. Exit"
echo -n "Choose an option: "
read -r choice

case $choice in
  1)
    install_docker
    ;;
  2)
    reinstall_docker
    ;;
  3)
    uninstall_docker
    ;;
  4)
    echo "Exiting."
    exit 0
    ;;
  *)
    echo "Invalid option. Exiting."
    exit 1
    ;;
esac
