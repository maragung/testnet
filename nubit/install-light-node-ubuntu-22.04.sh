#!/bin/bash

# Function to check if the service is running and stop it
check_and_stop_service() {
    if systemctl is-active --quiet nubitd; then
        echo "Stopping running nubitd service..."
        sudo systemctl stop nubitd
    fi
}

# Function for full installation
install_all() {
    # Run installation script from nubit.sh
    curl -sL1 https://nubit.sh | bash
}

# Function to create and configure the service
setup_service() {
    # Ensure the nubit-node folder exists and is accessible
    NODE_DIR="/home/$(whoami)/nubit-node"
    mkdir -p "$NODE_DIR"

    # Download start.sh to nubit-node folder
    curl -o "$NODE_DIR/start.sh" https://nubit.sh/start.sh
    chmod +x "$NODE_DIR/start.sh"

    # Create service file for systemd
    SERVICE_FILE="/etc/systemd/system/nubitd.service"
    if [ -f "$SERVICE_FILE" ]; then
        echo "Removing existing nubitd service..."
        sudo systemctl disable nubitd
        sudo rm "$SERVICE_FILE"
    fi

    sudo tee "$SERVICE_FILE" > /dev/null <<EOL
[Unit]
Description=Nubit Node Service
After=network.target

[Service]
ExecStart=/bin/bash $NODE_DIR/start.sh
Restart=always
User=$(whoami)
Environment=PATH=/usr/bin:/usr/local/bin
WorkingDirectory=$NODE_DIR

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd, enable and start nubitd service
    sudo systemctl daemon-reload
    sudo systemctl enable nubitd
    sudo systemctl start nubitd

    echo "Service setup complete."

    # Display the latest logs from the nubitd service
    echo "Displaying the latest logs from the nubitd service:"
    journalctl -u nubitd -n 10 --no-pager
}

# Function to read logs interactively
read_logs() {
    echo "Reading logs interactively for nubitd service. Press Ctrl+C to exit."
    sudo journalctl -u nubitd -f
}

# Function to uninstall the service and remove nubit-node
uninstall_service() {
    # Confirm before uninstalling
    read -r -p "Are you sure you want to uninstall the node service? Have you backed up your data? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Uninstallation aborted."
        exit 1
    fi

    # Stop and disable the service if it exists
    SERVICE_FILE="/etc/systemd/system/nubitd.service"
    if [ -f "$SERVICE_FILE" ]; then
        echo "Stopping and disabling nubitd service..."
        sudo systemctl stop nubitd
        sudo systemctl disable nubitd
        sudo rm "$SERVICE_FILE"
        sudo systemctl daemon-reload
    fi

    # Remove the nubit-node directory in home
    NODE_DIR_HOME="/home/$(whoami)/nubit-node"
    if [ -d "$NODE_DIR_HOME" ]; then
        echo "Removing nubit-node directory in home..."
        rm -rf "$NODE_DIR_HOME"
    fi

    # Remove the nubit-node directory in root
    NODE_DIR_ROOT="/root/nubit-node"
    if [ -d "$NODE_DIR_ROOT" ]; then
        echo "Removing nubit-node directory in root..."
        sudo rm -rf "$NODE_DIR_ROOT"
    fi

    # Rename the .nubit-light-nubit-alphatestnet-1 directory in /root
    DATA_DIR_ROOT="/root/.nubit-light-nubit-alphatestnet-1"
    BACKUP_DIR_ROOT="/root/.backup_nubit-light-nubit-alphatestnet-1"
    if [ -d "$DATA_DIR_ROOT" ]; then
        echo "Renaming data directory in /root to backup..."
        sudo mv "$DATA_DIR_ROOT" "$BACKUP_DIR_ROOT"
    fi

    # Rename the .nubit-light-nubit-alphatestnet-1 directory in /home/username
    DATA_DIR_HOME="/home/$(whoami)/.nubit-light-nubit-alphatestnet-1"
    BACKUP_DIR_HOME="/home/$(whoami)/.backup_nubit-light-nubit-alphatestnet-1"
    if [ -d "$DATA_DIR_HOME" ]; then
        echo "Renaming data directory in home to backup..."
        mv "$DATA_DIR_HOME" "$BACKUP_DIR_HOME"
    fi

    echo "Uninstallation complete."
}

# Display menu options
echo "Select installation option:"
echo "1) Install Node"
echo "2) Install Service"
echo "3) Read logs interactively"
echo "4) Uninstall node"

# Use read with -r -p options to ensure it reads correctly
read -r -p "Enter your choice (1, 2, 3, or 4): " choice

case $choice in
    1)
        echo "Performing node installation..."
        check_and_stop_service
        install_all
        setup_service
        ;;
    2)
        echo "Performing service install only..."
        check_and_stop_service
        setup_service
        ;;
    3)
        echo "Reading logs interactively..."
        read_logs
        ;;
    4)
        echo "Uninstalling service..."
        check_and_stop_service
        uninstall_service
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac



echo "Process complete. To start the service: sudo systemctl start nubitd"
echo "To restart the service: sudo systemctl restart nubitd"
echo "To stop the service: sudo systemctl stop nubitd"
echo "To check the status of the service: sudo systemctl status nubitd"
echo "To read logs again: sudo journalctl -u nubitd -f"
