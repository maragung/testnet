#!/bin/bash
echo "Downloading updated files......"
wget https://github.com/anoma/namada/releases/download/v0.23.1/namada-v0.23.1-Linux-x86_64.tar.gz
tar xvzf namada-v0.23.1-Linux-x86_64.tar.gz
rm namada-v0.23.1-Linux-x86_64.tar.gz
cd namada-v0.23.1-Linux-x86_64
echo "Stopping service..."
sudo systemctl stop namadad
sleep 10
sudo cp ./namada* /usr/local/bin/
sudo systemctl start namadad
echo "Service started successfully."
sudo journalctl -u namadad -f -o cat
