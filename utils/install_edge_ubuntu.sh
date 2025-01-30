#!/bin/bash

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or log in as root."
    exit 1
fi

# Step 1: System Update
echo "Updating system packages..."
apt update && apt upgrade -y
apt --fix-broken install -y

# Step 2: Install Required Dependencies
echo "Installing required dependencies..."
apt install -y software-properties-common apt-transport-https curl ca-certificates

# Step 3: Add Microsoft Edge Repository
echo "Adding Microsoft GPG key..."
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft-edge.gpg

echo "Adding Edge repository to sources.list..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list

# Update package list
echo "Refreshing package list..."
apt update

# Step 4: Install Microsoft Edge
echo "Installing Microsoft Edge Stable..."
apt install -y microsoft-edge-stable

# Verify installation
echo "Installed Microsoft Edge version:"
microsoft-edge --version

# Optional: Install Beta Version
# echo "Installing Microsoft Edge Beta..."
# apt install -y microsoft-edge-beta
# echo "Beta Version:"
# microsoft-edge-beta --version

echo "Installation complete! Microsoft Edge has been successfully installed."
