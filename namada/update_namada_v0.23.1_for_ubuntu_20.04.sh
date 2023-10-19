#!/bin/bash
echo "Special updater for Ubuntu 20.04"
echo "Downloading updated files......"
wget https://github.com/maragung/namada/releases/download/namada-v0.23.1/namada-v0.23.1.tar.gz
tar xvzf namada-v0.23.1.tar.gz
rm namada-v0.23.1.tar.gz
cd namada-v0.23.1
sudo systemctl stop namadad
echo "Stopping service..."
sleep 10
sudo cp ./namada* /usr/local/bin/
sudo systemctl start namadad
echo "Service started successfully."
sudo journalctl -u namadad -f -o cat
