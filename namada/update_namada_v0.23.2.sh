#!/bin/bash
echo "Downloading updated files......"
wget -O namada_0.23.2.tar.gz https://github.com/maragung/namada/releases/download/namada-v0.23.2/namada_0.23.2.tar.gz
echo "Stopping service..."
sudo systemctl stop namadad
sleep 10
sudo tar -xzvf namada_0.23.2.tar.gz -C /usr/local/bin/
sudo systemctl start namadad
echo "Service started successfully."
namada --version
sudo journalctl -u namadad -f -o cat
