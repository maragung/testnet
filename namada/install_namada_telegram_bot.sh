#!/bin/bash

# Get the directory where the script is located
current_directory=$(dirname "$0")

# Get the default user and group
default_user=$(id -u -n)
default_group=$(id -g -n)

# Clone the repository from GitHub
git clone https://github.com/maragung/namada-bot "$current_directory/namada-bot"
cd "$current_directory/namada-bot"

# Get input for telegramToken from the user
read -p "Enter the telegramToken value: " telegramToken

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

# Create the service file in the systemd directory to run "node index.js"
cat <<EOF | sudo tee /etc/systemd/system/namada-bot.service >/dev/null
[Unit]
Description=Service to run Namada Bot

[Service]
ExecStart=/usr/bin/node index.js
WorkingDirectory=$current_directory/namada-bot  # Perbaikan pada jalur direktori di sini
Restart=always
RestartSec=10
User=$default_user
Group=$default_group
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF


# Start the service and enable it to run at boot
sudo systemctl start namada-bot
sudo systemctl enable namada-bot

echo "Installation completed. The 'namada-bot' service has been started."
