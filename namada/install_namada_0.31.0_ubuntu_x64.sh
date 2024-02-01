#!/bin/bash
echo "Downloading files......"
wget https://github.com/cometbft/cometbft/releases/download/v0.37.2/cometbft_0.37.2_linux_amd64.tar.gz
tar xvzf cometbft_0.37.2_linux_amd64.tar.gz
sudo cp ./cometbft /usr/local/bin/
chmod +x /usr/local/bin/cometbft
rm -rf cometbft_0.37.2_linux_amd64.tar.gz


wget -O namada-v0.31.0-Linux-x86_64.tar.gz https://github.com/anoma/namada/releases/download/v0.31.0/namada-v0.31.0-Linux-x86_64.tar.gz
tar xvzf namada-v0.31.0-Linux-x86_64.tar.gz
rm namada-v0.31.0-Linux-x86_64.tar.gz
cd namada-v0.31.0-Linux-x86_64
wait
sudo cp ./namada* /usr/local/bin/
namada -V

export CHAIN_ID="shielded-expedition.b40d8e9055"
namada client utils join-network --chain-id $CHAIN_ID
wait


echo "Show node logs: sudo journalctl -u namadad -f -o cat"



