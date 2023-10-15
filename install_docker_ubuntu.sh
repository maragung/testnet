#!/bin/bash

install_docker() {
    echo "Updating package information..."
    sudo apt update

    echo "Installing necessary packages..."
    sudo apt install apt-transport-https ca-certificates curl software-properties-common

    echo "Adding Docker's GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "Adding Docker repository..."
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

    echo "Installing Docker..."
    sudo apt install docker-ce

    # Add current user to the 'docker' group
    add_user_to_docker_group
}

uninstall_docker() {
    echo "Removing Docker..."
    sudo apt purge docker-ce
    sudo apt autoremove --purge
    sudo rm -rf /var/lib/docker
}

check_docker_status() {
    echo "Checking Docker service status..."
    sudo systemctl status docker
}

add_user_to_docker_group() {
    CURRENT_USER=$(whoami)

    echo "Adding user '$CURRENT_USER' to the 'docker' group..."
    sudo usermod -aG docker "$CURRENT_USER"
    su - "$CURRENT_USER" -c "id -nG"
}

# Main script
echo "Select an option:"
echo "1. Install Docker"
echo "2. Uninstall Docker"
echo "3. Check Status"
echo "4. Exit"

read -p "Enter your choice: " choice

case $choice in
    1) install_docker ;;
    2) uninstall_docker ;;
    3) check_docker_status ;;
    4) echo "Exiting script. Goodbye!"; exit 0 ;;
    *) echo "Invalid choice. Exiting script."; exit 1 ;;
esac


