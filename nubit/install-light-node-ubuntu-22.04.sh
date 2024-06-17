#!/bin/bash

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

# Display menu options
echo "Select installation option:"
echo "1) Full installation"
echo "2) Install Service"
echo "3) Read logs interactively"

# Use read with -r -p options to ensure it reads correctly
read -r -p "Enter your choice (1, 2, or 3): " choice

case $choice in
    1)
        echo "Performing full installation..."
        install_all
        setup_service
        ;;
    2)
        echo "Performing service install only..."
        setup_service
        ;;
    3)
        echo "Reading logs interactively..."
        read_logs
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Process complete. To read logs again, type: journalctl -u nubitd -f"
