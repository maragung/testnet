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

echo "Update [Berkeley Testnet Release 2.0.0rampup6 (ITN RC2)]"
sudo apt-get update
sudo systemctl stop mina
sudo apt-get install -y mina-berkeley=2.0.0rampup6-4061884
echo "Mina node has been updated successfully."
mina version
sudo systemctl start mina
echo "To restart the Mina service, use: sudo systemctl restart mina"
echo "To check the status of the Mina service, use: sudo systemctl status mina"
