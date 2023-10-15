#!/bin/bash

KEY_PAIR_FILE=~/keys/keypair
KEYS_FILE=~/keys/my-wallet
KEYS_FILE_PUB=~/keys/my-wallet.pub

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

save_to_wallet() {
    read -p "Paste the code (private key/json) from the 'community-***-key' file that you got in the email and press ENTER: " wallet_info
    rm -rf $KEYS_FILE
    echo "$wallet_info" >> "$KEYS_FILE"
    echo "Private Key saved to the $KEYS_FILE: $wallet_info"
}

save_to_wallet_pub() {
    read -p "Paste the code (public key) from the 'community-***-key.pub' file that you got in the email and press ENTER: " wallet_info
    rm -rf $KEYS_FILE_PUB
    echo "$wallet_info" >> "$KEYS_FILE_PUB"
    echo "Public key saved to the $KEYS_FILE_PUB: $wallet_info"
}

save_to_wallet_password() {
    echo -n "Enter the value for UPTIME_PRIVKEY_PASS: "
    read UPTIME_PRIVKEY_PASS

    echo -n "Enter the value for MINA_LIBP2P_PASS: "
    read MINA_LIBP2P_PASS

    echo -n "Enter the value for MINA_PRIVKEY_PASS: "
    read MINA_PRIVKEY_PASS

    echo "export RAYON_NUM_THREADS=6" >> ~/.bash_profile
    echo "export UPTIME_PRIVKEY_PASS=\"$UPTIME_PRIVKEY_PASS\"" >> ~/.bash_profile
    echo "export MINA_LIBP2P_PASS=\"$MINA_LIBP2P_PASS\"" >> ~/.bash_profile
    echo "export MINA_PRIVKEY_PASS=\"$MINA_PRIVKEY_PASS\"" >> ~/.bash_profile

    echo "Variables have been set and saved in ~/.bash_profile"
}

save_to_ip() {
    # Get the current IP address and recommend it
    CURRENT_IP=$(curl -s ifconfig.me)
    echo "The current IP address is: $CURRENT_IP"
    echo -n "Do you want to use this IP address? (y/n): "
    read USE_CURRENT_IP

    # Check if the user wants to use the current IP
    if [ "$USE_CURRENT_IP" == "y" ]; then
      IP_ADDRESS=$CURRENT_IP
    else
      echo -n "Enter the IP address you want to use: "
      read IP_ADDRESS
    fi
    echo "export IP_ADDRESS=\"$IP_ADDRESS\"" >> ~/.bash_profile
    echo "IP have been set and saved in ~/.bash_profile"
}

save_to_keypair() {
    # Get the current IP address and recommend it
    echo "Create a libp2p key pair for a node the first time and persist it."
    mina libp2p generate-keypair -privkey-path $KEY_PAIR_FILE
    echo "Keypair location: $KEY_PAIR_FILE"
}

display_menu() {
    echo "Mina Manager"
    echo "1. Install Mina and dependencies"
    echo "2. Set Key & Password"
    echo "3. Remove Mina"
    echo "4. Exit"
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
            save_to_wallet
            save_to_wallet_pub
            save_to_wallet_password
            save_to_ip
            save_to_keypair
            break
            ;;
        3)
            remove_mina
            break
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
