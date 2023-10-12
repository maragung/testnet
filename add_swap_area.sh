#!/bin/bash

echo -e '\nChecking and adding swap area...\n'

# Check if 'swapfile' exists
if [ -e $HOME/swapfile ]; then
    echo -e '\nSwap file already exists, skipping.\n'
else
    # If swapfile doesn't exist, start the process of creating a swapfile in the home directory
    cd $HOME

    # Allocate 8GB of space for the swapfile
    sudo fallocate -l 8G $HOME/swapfile

    # Fill the swapfile with zeros using dd
    sudo dd if=/dev/zero of=swapfile bs=1K count=8M

    # Set permissions for the swapfile
    sudo chmod 600 $HOME/swapfile

    # Create swap on the swapfile
    sudo mkswap $HOME/swapfile

    # Activate the swapfile
    sudo swapon $HOME/swapfile

    # Display information about the swap
    sudo swapon --show

    # Add an entry for the swapfile in /etc/fstab
    echo $HOME'/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

    # Print a completion message
    echo -e '\nSwap file added successfully.\n'
fi
