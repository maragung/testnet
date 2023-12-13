#!/bin/bash

# Input prompts for the user
read -p "Enter your ALIAS (your_moniker): " ALIAS
read -p "Enter your EMAIL (your_email): " EMAIL
read -p "Enter your IP (ip): " IP_SUFFIX
read -p "Enter your VALIDATOR_ALIAS (Validator Name): " VALIDATOR_ALIAS

# Confirmation of entered data
echo "Entered Data:"
echo "ALIAS: $ALIAS"
echo "EMAIL: $EMAIL"
echo "IP: $IP_SUFFIX:26656"
echo "VALIDATOR_ALIAS: $VALIDATOR_ALIAS"

read -p "Is the entered data correct? (y/n): " CONFIRMATION

# Check user confirmation
if [ "$CONFIRMATION" != "y" ]; then
    echo "Please re-run the script and enter the correct data."
    exit 1
fi

# Combining IP with port
IP="$IP_SUFFIX:26656"

# Generate pre-genesis key after confirmation
namadaw --pre-genesis key gen --alias $ALIAS
wait
# Path for the transactions.toml file
TX_FILE_PATH="$HOME/.local/share/namada/pre-genesis/transactions.toml"

# Execute the command once to get the established account address
ESTABLISHED_ACCOUNT=$(namadac utils init-genesis-established-account --path $TX_FILE_PATH --aliases $ALIAS)
wait
ESTABLISHED_ACCOUNT_ADDRESS=$(echo "$ESTABLISHED_ACCOUNT" | grep -oP 'Derived established account address: \K(.*)')

echo "ESTABLISHED_ACCOUNT_ADDRESS: $ESTABLISHED_ACCOUNT_ADDRESS"


# Initialize validator
INIT_GENESIS=$(namadac utils init-genesis-validator --address $ESTABLISHED_ACCOUNT_ADDRESS --alias $VALIDATOR_ALIAS --net-address $IP --commission-rate 0.05 --max-commission-rate-change 0.01 --self-bond-amount $SELF_BOND_AMOUNT --email $EMAIL --path $TX_FILE_PATH)
wait
echo "INIT_GENESIS: $INIT_GENESIS"
# Sign transactions
namadac utils sign-genesis-txs \
    --path $TX_FILE_PATH \
    --output $HOME/.local/share/namada/pre-genesis/signed-transactions.toml \
    --alias $VALIDATOR_ALIAS


