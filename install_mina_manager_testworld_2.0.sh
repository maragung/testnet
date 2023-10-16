#!/bin/bash

export KEY_PAIR_FILE=~/keys/keypair
export KEYS_FILE=~/keys/my-wallet
export KEYS_FILE_PUB=~/keys/my-wallet.pub
source ~/.bashrc
source ~/.profile
    
install_dependencies() {
    echo "Installing dependencies..."
    apt-get install curl, wget, jq
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
    mkdir ~/keys -p
    chmod 700 ~/keys
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

    export RAYON_NUM_THREADS=6
    export UPTIME_PRIVKEY_PASS="$UPTIME_PRIVKEY_PASS"
    export MINA_LIBP2P_PASS="$MINA_LIBP2P_PASS"
    export MINA_PRIVKEY_PASS="$MINA_PRIVKEY_PASS"
    source ~/.bashrc
    source ~/.profile
    echo "Variables have been set and saved in ~/.bash_profile"
}

save_to_ip() {
    # Get the current IP address and recommend it
    CURRENT_IP=$(curl -s ipinfo.io/ip)
    echo "The current IP address is: $CURRENT_IP"
    echo -n "Do you want to use this IP address? (y/n): "
    read USE_CURRENT_IP

    # Check if the user wants to use the current IP
    if [ "$USE_CURRENT_IP" == "y" ]; then
      IP_ADDRESS=$CURRENT_IP
    else
      echo -n "Enter the Your IP Address: "
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


SERVICE_FILE="/etc/systemd/system/mina.service"

generate_service_file() {
    cat <<EOL >"$SERVICE_FILE"
[Unit]
Description=Mina Protocol
After=network.target

[Service]
User=root
Environment=RAYON_NUM_THREADS=6
Environment=UPTIME_PRIVKEY_PASS=$UPTIME_PRIVKEY_PASS
Environment=MINA_LIBP2P_PASS=$MINA_LIBP2P_PASS
Environment=MINA_PRIVKEY_PASS=$MINA_PRIVKEY_PASS
Environment=IP_ADDRESS=$IP_ADDRESS
Environment=KEY_PAIR_FILE=$KEY_PAIR_FILE
Environment=KEYS_FILE=$KEYS_FILE
ExecStart=/usr/local/bin/mina daemon --peer-list-url https://storage.googleapis.com/seed-lists/testworld-2-0_seeds.txt --log-json --log-snark-work-gossip true --internal-tracing --insecure-rest-server --log-level Debug --file-log-level Debug --config-directory /root/.mina --external-ip \$IP_ADDRESS --itn-keys f1F38+W3zLcc45fGZcAf9gsZ7o9Rh3ckqZQw6yOJiS4=,6GmWmMYv5oPwQd2xr6YArmU1YXYCAxQAxKH7aYnBdrk=,ZJDkF9EZlhcAU1jyvP3m9GbkhfYa0yPV+UdAqSamr1Q=,NW2Vis7S5G1B9g2l9cKh3shy9qkI1lvhid38763vZDU=,Cg/8l+JleVH8yNwXkoLawbfLHD93Do4KbttyBS7m9hQ= --itn-graphql-port 3089 --uptime-submitter-key \$UPTIME_PRIVKEY_PASS --uptime-url https://block-producers-uptime-itn.minaprotocol.tools/v1/submit --metrics-port 10001 --enable-peer-exchange true --libp2p-keypair \$KEY_PAIR_FILE --log-precomputed-blocks true --max-connections 200 --generate-genesis-proof true --block-producer-key \$KEYS_FILE --node-status-url https://nodestats-itn.minaprotocol.tools/submit/stats --node-error-url https://nodestats-itn.minaprotocol.tools/submit/stats --file-log-rotations 500
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL
}

services_systemd_menu() {
    echo "Services/Systemd Menu"
    echo "1. Install Service"
    echo "2. Restart Service"
    echo "3. Stop Service"
    echo "4. Check Service Status"
    echo "5. Check Service Log"
    echo "6. Remove Service"
}


handle_services_systemd_menu() {
    local choice
    while true; do
        read -p "Enter your choice: " choice
        case $choice in
            1)
                echo "You chose to install the service."
                generate_service_file
                sudo systemctl daemon-reload
                sudo systemctl enable mina
                sudo systemctl start mina
                exit 0
                ;;
            2)
                echo "You chose to restart the service."
                sudo systemctl restart mina
                pkill -f mina
                exit 0
                ;;
            3)
                echo "You chose to stop the service."
                sudo systemctl stop mina
                exit 0
                ;;
            4)
                echo "You chose to check the service status."
                sudo systemctl status mina
                exit 0
                ;;
            5)
                echo "You chose to check the service log."
                sudo journalctl -u mina -n 1000 -f
                exit 0
                ;;
            6)
                echo "You chose to remove the service."
                sudo systemctl stop mina
                sudo systemctl disable mina
                sudo systemctl daemon-reload
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}

display_menu() {
    echo "Mina Manager"
    echo "1. Install Mina and dependencies"
    echo "2. Set Key & Password"
    echo "3. Services/Systemd"
    echo "4. Mina Status"
    echo "5. Remove Mina"
    echo "6. Exit"
}

while true; do
    display_menu
    read -p "Enter your choice: " main_choice
    case $main_choice in
        1)
            install_dependencies
            install_mina
            exit 0
            ;;
        2)
            save_to_wallet
            save_to_wallet_pub
            save_to_wallet_password
            save_to_ip
            save_to_keypair
            exit 0
            ;;
        3)
            services_systemd_menu
            handle_services_systemd_menu
            exit 0
            ;;
        4)
            mina client status
            exit 0
            ;;
        5)
            remove_mina
            exit 0
            ;;
        6)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
