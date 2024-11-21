#!/bin/bash



# Prompt user for necessary endpoints and configurations
read -p "Enter HTTPS TESTNET_HOLESKY_ENDPOINT: " TESTNET_HOLESKY_ENDPOINT
read -p "Enter HTTPS MAINNET_ENDPOINT: " MAINNET_ENDPOINT
read -p "Enter HTTPS HOLESKY ETH_RPC_URL: " ETH_RPC_URL
read -p "Enter WS HOLESKY ETH_WS_URL: " ETH_WS_URL

# Prompt for password
read -p "Enter password for the keys: " key_pass

# Stop the systemd service if it exists
if systemctl list-units --type=service | grep -q "zenrock-sidecar.service"; then
    echo "Stopping Zenrock-sidecar service..."
    sudo systemctl stop zenrock-sidecar
    sudo systemctl disable zenrock-sidecar
    sudo rm /etc/systemd/system/zenrock-sidecar.service
    sudo systemctl daemon-reload
    echo "Zenrock-sidecar service removed."
else
    echo "Zenrock-sidecar service not found."
fi

# Remove configuration files and directories
echo "Removing configuration files and directories..."
rm -rf $HOME/.zrchain
rm -rf $HOME/zenrock-validators

# Remove leftover files
rm -f $HOME/.zrchain/sidecar/config.yaml
rm -f $HOME/.zrchain/sidecar/eigen_operator_config.yaml
rm -f $HOME/.zrchain/sidecar/keys/ecdsa.key.json
rm -f $HOME/.zrchain/sidecar/keys/bls.key.json

# Optionally remove downloaded binary
if [[ -f "$HOME/.zrchain/sidecar/bin/validator_sidecar" ]]; then
    echo "Removing validator_sidecar binary..."
    rm -f $HOME/.zrchain/sidecar/bin/validator_sidecar
fi

echo "All related files and configurations have been removed."


# Clone the repository
cd $HOME
rm -rf zenrock-validators
git clone https://github.com/zenrocklabs/zenrock-validators

# Create necessary directories
mkdir -p $HOME/.zrchain/sidecar/bin
mkdir -p $HOME/.zrchain/sidecar/keys

# Remove old configuration files if they exist
rm -f $HOME/.zrchain/sidecar/config.yaml
rm -f $HOME/.zrchain/sidecar/eigen_operator_config.yaml

# Create or update config.yaml
cat <<EOF > $HOME/.zrchain/sidecar/config.yaml
grpc_port: 9191
state_file: "cache.json"
operator_config: "/root/.zrchain/sidecar/eigen_operator_config.yaml"
network: "testnet"
eth_oracle:
  rpc:
    local: "http://127.0.0.1:8545"
    testnet: "${TESTNET_HOLESKY_ENDPOINT}"
    mainnet: "${MAINNET_ENDPOINT}"
  contract_addrs:
    service_manager: "0x3AD648DfE0a6D80745ab2Ec97CB67c56bfBEc032"
    price_feed: "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"
  network_name: "Holešky Ethereum Testnet"
solana_rpc:
  testnet: "https://api.testnet.solana.com"
  mainnet: ""
proxy_rpc:
  url: ""
  user: ""
  password: ""
neutrino:
  path: "/root/.zrchain/sidecar/neutrino"
EOF



# Download binary
wget -O $HOME/.zrchain/sidecar/bin/validator_sidecar https://github.com/zenrocklabs/zrchain/releases/download/v5.3.4/validator_sidecar
chmod +x $HOME/.zrchain/sidecar/bin/validator_sidecar

# Build binary ecdsa
cd $HOME/zenrock-validators/utils/keygen/ecdsa && go build

# Build binary bls
cd $HOME/zenrock-validators/utils/keygen/bls && go build

# Generate ecdsa key
ecdsa_output_file=$HOME/.zrchain/sidecar/keys/ecdsa.key.json
ecdsa_creation=$($HOME/zenrock-validators/utils/keygen/ecdsa/ecdsa --password $key_pass -output-file $ecdsa_output_file)
ecdsa_address=$(echo "$ecdsa_creation" | grep "Public address" | cut -d: -f2)

# Generate bls key
bls_output_file=$HOME/.zrchain/sidecar/keys/bls.key.json
$HOME/zenrock-validators/utils/keygen/bls/bls --password $key_pass -output-file $bls_output_file

OPERATOR_VALIDATOR_ADDRESS=zenrockd q validation validator $(zenrockd keys show $WALLET --bech val -a)
echo "Validator address: $OPERATOR_VALIDATOR_ADDRESS"

# Create or update eigen_operator_config.yaml
cat <<EOF > $HOME/.zrchain/sidecar/eigen_operator_config.yaml
register_operator_on_startup: true
register_on_startup: true
production: true
operator_address: "$ecdsa_address"
operator_validator_address: "$OPERATOR_VALIDATOR_ADDRESS"
avs_registry_coordinator_address: 0xFbB0cbF0d14C8BaE1f36Cd4Dff792ca412b72Af0
operator_state_retriever_address: 0xe7FDe0EFCECBbcC25F326EdC80E6B79c1482dAaB
eth_rpc_url: "$ETH_RPC_URL"
eth_ws_url: "$ETH_WS_URL"
ecdsa_private_key_store_path: "/root/.zrchain/sidecar/keys/ecdsa.key.json"
bls_private_key_store_path: "/root/.zrchain/sidecar/keys/bls.key.json"
aggregator_server_ip_port_address: avs-aggregator.gardia.zenrocklabs.io:8090
eigen_metrics_ip_port_address: 0.0.0.0:9292
enable_metrics: true
metrics_address: 0.0.0.0:9292
node_api_ip_port_address: 0.0.0.0:9191
enable_node_api: true
token_strategy_addr: 0x80528D6e9A2BAbFc766965E0E26d5aB08D9CFaF9
service_manager_address: 0x3AD648DfE0a6D80745ab2Ec97CB67c56bfBEc032
zr_chain_rpc_address: localhost:9790
EOF


# Display ECDSA address
echo "ECDSA address: $ecdsa_address"
echo "Please fund your wallet address with Holesky $ETH before proceeding."

# Set up systemd service
sudo systemctl stop zenrock-sidecar 2>/dev/null
cat <<EOF | sudo tee /etc/systemd/system/zenrock-sidecar.service > /dev/null
[Unit]
Description=Zenrock-sidecar
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/.zrchain/sidecar/bin/validator_sidecar
Restart=on-failure
RestartSec=30
LimitNOFILE=65535
Environment="OPERATOR_BLS_KEY_PASSWORD=$key_pass"
Environment="OPERATOR_ECDSA_KEY_PASSWORD=$key_pass"
Environment="SIDECAR_CONFIG_FILE=$HOME/.zrchain/sidecar/config.yaml"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl enable zenrock-sidecar
sudo systemctl restart zenrock-sidecar && journalctl -u zenrock-sidecar -f -o cat
