#!/bin/bash

echo -e '\nRemoving swap area...\n'

# Check if 'swapfile' exists
if [ -e $HOME/swapfile ]; then
    # If swapfile exists, proceed to remove it
    sudo swapoff $HOME/swapfile  # Deactivate the swapfile
    sudo rm $HOME/swapfile       # Remove the swapfile

    # Remove the swapfile entry from /etc/fstab
    sudo sed -i "\|$HOME/swapfile|d" /etc/fstab

    echo -e '\nSwap area removed successfully.\n'
else
    echo -e '\nSwap file does not exist, nothing to remove.\n'
fi
