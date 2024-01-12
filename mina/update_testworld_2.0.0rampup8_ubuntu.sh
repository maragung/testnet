#!/bin/bash

echo -e "\033[32m"
cat << "EOF"
                  _                         _            
  __   __    ____ (_)__  ____   ____  _   _ (_)__    ____ 
 (__)_(__)  (____)(____)(____) (____)(_) (_)(____)  (____)
(_) (_) (_)( )_( )(_)  ( )_( )( )_(_)(_)_(_)(_) (_)( )_(_)
(_) (_) (_) (__)_)(_)   (__)_) (____) (___) (_) (_) (____)
                              (_)_(_)              (_)_(_)
                               (___)                (___)
EOF
echo -e "\033[0m"

echo "Update [Berkeley Testnet Release 2.0.0rampup8-56fa1db (ITN RC4)]"
sudo apt-get update
sudo systemctl stop mina
sudo apt-get install -y mina-berkeley=2.0.0rampup8-56fa1db
wait
echo "Mina node has been updated successfully."
mina version
wait
sudo systemctl start mina
wait
echo "To restart the Mina service, use: sudo systemctl restart mina"
echo "To check the status of the Mina service, use: sudo systemctl status mina"
echo "Read node logs, use: sudo journalctl -u mina -n 1000 -f"
echo "Read mina status, use: mina client status"
