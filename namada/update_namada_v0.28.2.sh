#!/bin/bash
echo "Downloading updated files......"
wget -O namada-v0.28.2-Linux-x86_64.tar.gz https://github.com/anoma/namada/releases/download/v0.28.2/namada-v0.28.2-Linux-x86_64.tar.gz
tar xvzf namada-v0.28.2-Linux-x86_64.tar.gz
rm namada-v0.28.2-Linux-x86_64.tar.gz
cd namada-v0.28.2-Linux-x86_64
echo "Stopping service..."
sudo systemctl stop namadad
wait
sudo cp ./namada* /usr/local/bin/
namada -V
wait
sudo systemctl start namadad
wait
echo "Service started successfully."
sudo journalctl -u namadad -f -o cat
