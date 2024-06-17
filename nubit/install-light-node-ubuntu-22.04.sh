#!/bin/bash

# Function for full installation
install_all() {
    # Run installation script from nubit.sh
    curl -sL1 https://nubit.sh | bash
}

# Function to create and configure the service
setup_service() {
    # Create nubit-node folder in home directory
    mkdir -p /home/$(whoami)/nubit-node

    # Download start.sh to nubit-node folder
    curl -o /home/$(whoami)/nubit-node/start.sh https://nubit.sh/start.sh
    chmod +x /home/$(whoami)/nubit-node/start.sh

    # Create service to run start.sh
    cat <<EOL | sudo tee /etc/systemd/system/nubitd.service
[Unit]
Description=Nubit Node Service
After=network.target

[Service]
ExecStart=/bin/bash /home/$(whoami)/nubit-node/start.sh
Restart=always
User=$(whoami)
Environment=PATH=/usr/bin:/usr/local/bin
WorkingDirectory=/home/$(whoami)/nubit-node

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
    journalctl -u nubitd -f
}

# Display menu options
echo "Select installation option:"
echo "1) Full installation"
echo "2) Install Service"

# Use read with -r -p options to ensure it reads correctly
read -r -p "Enter your choice (1 or 2): " choice

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
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Process complete."
