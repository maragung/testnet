#!/bin/bash

install_dependencies() {
    echo "Installing dependencies..."
    wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb
    sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb

    wget https://mirrors.edge.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb
    sudo dpkg -i libffi6_3.2.1-8_amd64.deb

    wget http://ftp.de.debian.org/debian/pool/main/p/procps/libprocps7_3.3.15-2_amd64.deb
    sudo dpkg -i libprocps7_3.3.15-2_amd64.deb

    rm *.deb
}

install_mina() {
    echo "Installing Mina..."
    sudo rm /etc/apt/sources.list.d/mina*.list
    echo "deb [trusted=yes] http://packages.o1test.net/ buster rampup" | sudo tee /etc/apt/sources.list.d/mina-rampup.list
    sudo apt-get update
    sudo apt-get install -y mina-berkeley=2.0.0rampup5-55b7818
    which mina
    mina version
    echo "Mina installed successfully."
}

remove_mina() {
    echo "Removing Mina..."
    sudo apt-get remove --purge mina-berkeley
    sudo apt-get autoremove
    sudo rm /etc/apt/sources.list.d/mina*.list
    echo "Mina removed successfully."
}

display_menu() {
    echo "Mina Manager"
    echo "1. Install Mina and dependencies"
    echo "2. Remove Mina"
    echo "3. Exit"
}

# Display the menu
display_menu

while true; do
    read -p "Enter your choice: " choice
    case $choice in
        1)
            install_dependencies
            install_mina
            break
            ;;
        2)
            remove_mina
            break
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
