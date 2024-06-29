#!/bin/bash

# Define variables
CHAIN_ID="luminara-position.5eef10f5ab83"
NAMADA_DIR="${HOME}/.local/share/namada"
TEMP_DIR="${HOME}/tmp"
SNAPSHOT_URL="https://testnet.luminara.icu/luminara-position.5eef10f5ab83_2024-06-24T13.08.tar.lz4"
SNAPSHOT_FILE="${TEMP_DIR}/snapshot.tar.lz4"
EXTRACT_DIR="${TEMP_DIR}/extracted_snapshot"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to initialize environment variables
initialize_env_vars() {
    echo "Please enter the following information or press enter to accept the default values:"
    read -p "Namada Version: " NAMADA_VERSION
    NAMADA_VERSION=${NAMADA_VERSION:-v0.39.0}
    read -p "Namada Port [26]: " NAMADA_PORT
    NAMADA_PORT=${NAMADA_PORT:-26}
    read -p "Validator Alias [CHOOSE_A_NAME_FOR_YOUR_VALIDATOR]: " NAMADA_ALIAS
    NAMADA_ALIAS=${NAMADA_ALIAS:-CHOOSE_A_NAME_FOR_YOUR_VALIDATOR}
    read -p "Memo [CHOOSE_YOUR_tpknam_ADDRESS]: " NAMADA_MEMO
    NAMADA_MEMO=${NAMADA_MEMO:-CHOOSE_YOUR_tpknam_ADDRESS}
    read -p "Wallet [wallet]: " NAMADA_WALLET
    NAMADA_WALLET=${NAMADA_WALLET:-wallet}
    read -p "Chain ID [${CHAIN_ID}]: " NAMADA_CHAIN_ID
    NAMADA_CHAIN_ID=${NAMADA_CHAIN_ID:-${CHAIN_ID}}
    NAMADA_PUBLIC_IP=$(wget -qO- eth0.me)
    NAMADA_TM_HASH="v0.1.4-abciplus"
    NAMADA_BASE_DIR="$HOME/.local/share/namada"

    # Export environment variables
    echo "export NAMADA_VERSION=${NAMADA_VERSION}" >> $HOME/.bash_profile
    echo "export NAMADA_PORT=${NAMADA_PORT}" >> $HOME/.bash_profile
    echo "export NAMADA_ALIAS=${NAMADA_ALIAS}" >> $HOME/.bash_profile
    echo "export NAMADA_MEMO=${NAMADA_MEMO}" >> $HOME/.bash_profile
    echo "export NAMADA_WALLET=${NAMADA_WALLET}" >> $HOME/.bash_profile
    echo "export NAMADA_PUBLIC_IP=${NAMADA_PUBLIC_IP}" >> $HOME/.bash_profile
    echo "export NAMADA_TM_HASH=${NAMADA_TM_HASH}" >> $HOME/.bash_profile
    echo "export NAMADA_CHAIN_ID=${NAMADA_CHAIN_ID}" >> $HOME/.bash_profile
    echo "export NAMADA_BASE_DIR=${NAMADA_BASE_DIR}" >> $HOME/.bash_profile
    source $HOME/.bash_profile

}

display_variables() {
    echo "Please review the following variables:"
    echo -e "\e[1;37mNAMADA_PORT\e[0m: ${NAMADA_PORT:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_ALIAS\e[0m: ${NAMADA_ALIAS:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_MEMO\e[0m: ${NAMADA_MEMO:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_WALLET\e[0m: ${NAMADA_WALLET:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_PUBLIC_IP\e[0m: ${NAMADA_PUBLIC_IP:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_TM_HASH\e[0m: ${NAMADA_TM_HASH:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_CHAIN_ID\e[0m: ${NAMADA_CHAIN_ID:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_BASE_DIR\e[0m: ${NAMADA_BASE_DIR:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_VERSION\e[0m: ${NAMADA_VERSION:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mCHAIN_ID\e[0m: ${CHAIN_ID:-\e[1;31mnot set\e[0m}"
    echo -e "\e[1;37mNAMADA_DIR\e[0m: ${NAMADA_DIR:-\e[1;31mnot set\e[0m}"

    read -p "Are these values correct? Proceed with installation? (Y/n): " choice
    choice=${choice:-Y}
    if [ "$choice" != "Y" ] && [ "$choice" != "y" ]; then
        echo "Installation aborted."
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    sudo apt update
    sudo apt-get install -y make git-core libssl-dev pkg-config libclang-12-dev build-essential protobuf-compiler
}

# Install Go
install_go() {
    cd $HOME
    if ! command_exists go; then
        VER="1.20.3"
        wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
        rm "go$VER.linux-amd64.tar.gz"
        [ ! -f ~/.bash_profile ] && touch ~/.bash_profile
        echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
        source $HOME/.bash_profile
    fi
    [ ! -d ~/go/bin ] && mkdir -p ~/go/bin
}

# Install Rust
install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
}

# Install CometBFT
install_cometbft() {
    cd $HOME
    rm -rf cometbft
    git clone https://github.com/cometbft/cometbft.git
    cd cometbft
    git checkout v0.37.2
    make build
    sudo cp $HOME/cometbft/build/cometbft /usr/local/bin/
    cometbft version
}

# Platform selection for Namada installation
select_platform() {
    echo "Select your platform:"
    echo "1. Darwin-arm64"
    echo "2. MSYS_NT-10.0-20348"
    echo "3. Linux-x86_64"
    read -p "Enter the number corresponding to your platform: " platform_choice

    case $platform_choice in
        1)
            PLATFORM="Darwin-arm64"
            ;;
        2)
            PLATFORM="dirty-MSYS_NT-10.0-20348-x86_64"
            ;;
        3)
            PLATFORM="Linux-x86_64"
            ;;
        *)
            echo "Invalid choice. Installation aborted."
            exit 1
            ;;
    esac

    # Install Namada
    echo "Installing Namada for ${PLATFORM}..."
    NAMADA_TAR="namada-${NAMADA_VERSION}-${PLATFORM}.tar.gz"
    wget -O "${TEMP_DIR}/namada.tar.gz" "https://github.com/anoma/namada/releases/download/${NAMADA_VERSION}/${NAMADA_TAR}"
    tar -xzf "${TEMP_DIR}/namada.tar.gz" -C "${TEMP_DIR}"
    sudo mv "${TEMP_DIR}/namada" /usr/local/bin/namada
    namada --version
}

# Initialize Namada node
initialize_namada_node() {
    export NAMADA_NETWORK_CONFIGS_SERVER="https://testnet.luminara.icu/configs"
    namadac utils join-network --chain-id $CHAIN_ID --dont-prefetch-wasm

    # Download and extract WASM files
    echo "Downloading and extracting WASM files..."
    wget -O "${TEMP_DIR}/wasm.tar.gz" "https://testnet.luminara.icu/wasm.tar.gz"
    tar -xf "${TEMP_DIR}/wasm.tar.gz" -C "${TEMP_DIR}"
    mkdir -p "${NAMADA_DIR}/${CHAIN_ID}/wasm"
    cp "${TEMP_DIR}/wasm"/* "${NAMADA_DIR}/${CHAIN_ID}/wasm"

    # Add persistent peers
    echo "Adding persistent peers..."
    PERSISTENT_PEERS="tcp://af427e348cd45dd7308be4ea58f1492098e057b8@143.198.36.225:26656"
    sed -i "s/^persistent_peers = .*/persistent_peers = \"${PERSISTENT_PEERS}\"/" "${NAMADA_DIR}/${CHAIN_ID}/config.toml"

    # Update ports in the config file
    sed -i.bak -e "s%:26658%:${NAMADA_PORT}658%g;
    s%:26657%:${NAMADA_PORT}657%g;
    s%:26656%:${NAMADA_PORT}656%g;
    s%:26545%:${NAMADA_PORT}545%g;
    s%:8545%:${NAMADA_PORT}545%g;
    s%:26660%:${NAMADA_PORT}660%g" "${NAMADA_DIR}/${CHAIN_ID}/config.toml"
}

# Create systemd service file for Namada node
create_systemd_service() {
    sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=Namada Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$NAMADA_BASE_DIR
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=$(which namada) node ledger run
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
}

# Start Namada node service
start_namada_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable namadad
    sudo systemctl start namadad
}

# Use snapshot for faster syncing
use_snapshot() {
    echo "Using snapshot for faster syncing..."
    sudo systemctl stop namadad
    if ! command_exists lz4; then
        sudo apt update
        sudo apt install -y lz4
    fi
    wget -O "${SNAPSHOT_FILE}" "${SNAPSHOT_URL}"
    mkdir -p "${EXTRACT_DIR}"
    lz4 -c -d "${SNAPSHOT_FILE}" | tar -x -C "${EXTRACT_DIR}"

    # Backup priv_validator_state.json if validator
    if [ -f "${NAMADA_DIR}/${CHAIN_ID}/cometbft/data/priv_validator_state.json" ]; then
        mv "${NAMADA_DIR}/${CHAIN_ID}/cometbft/data/priv_validator_state.json" "${TEMP_DIR}/priv_validator_state.json.bak"
    fi

    # Copy extracted directories
    cp -r "${EXTRACT_DIR}/db" "${NAMADA_DIR}/${CHAIN_ID}/"
    cp -r "${EXTRACT_DIR}/cometbft/data" "${NAMADA_DIR}/${CHAIN_ID}/cometbft/"

    sudo systemctl start namadad
}

# Read service logs
read_service_logs() {
    sudo journalctl -u namadad.service
}

# Backup private validator
backup_private_validator() {
    if [ -f "${NAMADA_DIR}/${CHAIN_ID}/cometbft/data/priv_validator_state.json" ]; then
        echo "Backing up private validator..."
        cp "${NAMADA_DIR}/${CHAIN_ID}/cometbft/data/priv_validator_state.json" "${HOME}/priv_validator_state.json.bak"
    else
        echo "Private validator file not found."
    fi
}

# Uninstall and clean up
uninstall_and_clean() {
    echo "Stopping Namada service..."
    sudo systemctl stop namadad

    echo "Removing Namada and related files..."
    sudo rm -rf /usr/local/bin/namada
    rm -rf $HOME/cometbft
    rm -rf $HOME/go
    rm -rf $HOME/.cargo

    echo "Cleaning up directories..."
    rm -rf $NAMADA_DIR
    rm -rf $TEMP_DIR

    echo "Uninstallation complete."
}

# Main menu
echo "Select an option:"
echo "1. Install Namada node and dependencies"
echo "2. Reinstall Rust, CometBFT, and Go"
echo "3. Stop service, download snapshot, and restart service"
echo "4. Read service logs"
echo "5. Backup private validator"
echo "6. Uninstall Namada and clean up"
read -p "Enter your choice [1-6]: " choice

case $choice in
    1)
        initialize_env_vars
        display_variables
        install_dependencies
        install_go
        install_rust
        install_cometbft
        select_platform
        initialize_namada_node
        create_systemd_service
        start_namada_service
        ;;
    2)
        install_rust
        install_cometbft
        install_go
        ;;
    3)
        use_snapshot
        ;;
    4)
        read_service_logs
        ;;
    5)
        backup_private_validator
        ;;
    6)
        uninstall_and_clean
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac
