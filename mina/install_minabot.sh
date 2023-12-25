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

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg make build-essential
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

NODE_MAJOR=18
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

sudo apt-get update
sudo apt-get install nodejs -y

echo "This is Mina Bot, used to monitor Mina Nodes in Testworld 2.0. Type /start in your bot to start"
sleep 3
git clone https://github.com/maragung/testworld_bot
cd testworld_bot
sudo chmod +x run.sh
read -p "Enter Bot TOKEN (Telegram): " new_token
sed -i "s/const TOKEN = \"\"/const TOKEN = \"$new_token\"/g" index.js
echo "TOKEN has been updated to: $new_token"
sudo apt install npm -y
npm install

unit_name="minabot"
current_dir="$(pwd)"
current_user="$USER"
current_group="$(id -gn)"
echo "Creating Mina Bot service..."

unit_content="[Unit]
Description=Testworld Mina Bot Service

[Service]
ExecStart=$current_dir/run.sh
Restart=always
User=$current_user
Group=$current_group
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production
WorkingDirectory=$current_dir

[Install]
WantedBy=multi-user.target
"
echo "$unit_content" | sudo tee /etc/systemd/system/$unit_name.service > /dev/null
sudo systemctl daemon-reload
sudo systemctl enable $unit_name
sudo systemctl start $unit_name

echo "Minabot service has been created successfully."
echo "To start the Minabot service, use: sudo systemctl start $unit_name"
echo "To stop the Minabot service, use: sudo systemctl stop $unit_name"
echo "To restart the Minabot service, use: sudo systemctl restart $unit_name"
echo "To check the status of the Minabot service, use: sudo systemctl status $unit_name"


