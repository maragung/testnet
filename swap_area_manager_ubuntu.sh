#!/bin/bash

create_swap() {
    read -p "Enter the swap size in gigabytes (e.g., 2 for 2GB): " swap_size_gb
    swap_size_mb=$((swap_size_gb * 1024))

    echo "Creating a swap file of size $swap_size_gb GB..."
    sudo fallocate -l ${swap_size_mb}M /swapfile

    echo "Setting permissions on the swap file..."
    sudo chmod 600 /swapfile

    echo "Setting up swap area..."
    sudo mkswap /swapfile

    echo "Enabling the swap file..."
    sudo swapon /swapfile

    echo "Swap file has been created and enabled."
    sudo swapon --show

    # Add an entry for the swapfile in /etc/fstab
    echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab

    echo -e '\nSwap file added successfully.\n'
}

resize_swap() {
    if [ -e /swapfile ]; then
        echo "Disabling the swap file before resizing..."
        sudo swapoff /swapfile

        read -p "Enter the new swap size in gigabytes (e.g., 4 for 4GB): " new_swap_size_gb
        new_swap_size_mb=$((new_swap_size_gb * 1024))

        echo "Resizing the swap file to $new_swap_size_gb GB..."
        sudo fallocate -l ${new_swap_size_mb}M /swapfile

        echo "Setting up swap area..."
        sudo mkswap /swapfile

        echo "Enabling the resized swap file..."
        sudo swapon /swapfile

        echo "Swap file has been resized and enabled."
        sudo swapon --show
    else
        echo "No swap file found. Please create a swap file first."
    fi
}

disable_swap() {
    echo "Disabling the swap file..."
    sudo swapoff /swapfile

    echo "Swap file has been disabled."
}

enable_swap() {
    echo "Enabling the swap file..."
    sudo swapon /swapfile

    echo "Swap file has been enabled."
    sudo swapon --show
}

# Main script
echo "Select an option:"
echo "1. Create Swap Area"
echo "2. Resize Swap Area"
echo "3. Disable Swap Area"
echo "4. Enable Swap Area"
echo "5. Exit"

read -p "Enter your choice: " choice

case $choice in
    1) create_swap ;;
    2) resize_swap ;;
    3) disable_swap ;;
    4) enable_swap ;;
    5) echo "Exiting script. Goodbye!"; exit 0 ;;
    *) echo "Invalid choice. Exiting script."; exit 1 ;;
esac
