#!/bin/bash

# Get the directory where the script is located
current_directory=$PWD

if [ -d "$current_directory/namada-bot" ]; then
    read -p "Folder 'namada-bot' already exists. Do you want to delete it? (y/n): " delete_folder
    if [ "$delete_folder" = "y" ]; then
        # Remove the 'namada-bot' folder and its contents
        rm -rf "$current_directory/namada-bot"
        echo "Folder 'namada-bot' deleted."
    else
        echo "Skipping deletion of 'namada-bot' folder."
        exit
    fi
fi
wait



# Clone the repository from GitHub
git clone https://github.com/maragung/namada-bot "namada-bot"
wait
cd "$current_directory/namada-bot"


echo "node \"$PWD/index.js\"" > "$current_directory/namada-bot/run.sh"

# Add execute permission to the run.sh file
chmod +x "$current_directory/namada-bot/run.sh"

# Get input for telegramToken from the user
read -p "Enter the Telegram Bot Token value: " telegramToken
wait

# Create the config.json file with the provided telegramToken value
cat <<EOF >config.json
{
  "telegramToken": "$telegramToken",
  "autoSendInterval": 2,
  "autoSendEnabled": false,
  "region": "Etc/GMT-7"
}
EOF

# Continue with installing dependencies using npm
npm install
wait

if [ -f /etc/systemd/system/namada-bot.service ]; then
    sudo systemctl stop namada-bot
    wait
    sudo systemctl disable namada-bot
    sudo rm /etc/systemd/system/namada-bot.service
    sudo systemctl daemon-reload
fi


CURRENT_PATH=$(pwd)
CURRENT_USER=$(id -u -n)
CURRENT_GROUP=$(id -g -n)

SERVICE_NAME="namada-bot"

# Membuat file unit service
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Isi file unit service
cat <<EOF > $SERVICE_FILE
[Unit]
Description=Namada Telegram Bot
After=network.target

[Service]
User=$CURRENT_USER
Group=$CURRENT_GROUP
WorkingDirectory=$CURRENT_PATH
ExecStart=/usr/bin/node $CURRENT_PATH/index.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF


chmod 644 $SERVICE_FILE

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME
sudo systemctl status $SERVICE_NAME


