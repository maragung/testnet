#!/bin/bash

# Menjalankan skrip instalasi dari nubit.sh
curl -sL1 https://nubit.sh | bash

# Membuat folder nubit-node di home directory
mkdir -p ~/nubit-node

# Download start.sh ke folder nubit-node
curl -o ~/nubit-node/start.sh https://nubit.sh/start.sh
chmod +x ~/nubit-node/start.sh

# Membuat service untuk menjalankan start.sh
cat <<EOL | sudo tee /etc/systemd/system/nubitd.service
[Unit]
Description=Nubit Node Service
After=network.target

[Service]
ExecStart=/bin/bash /home/$USER/nubit-node/start.sh
Restart=always
User=$USER
Environment=PATH=/usr/bin:/usr/local/bin
WorkingDirectory=/home/$USER/nubit-node

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start nubitd
sudo systemctl daemon-reload
sudo systemctl enable nubitd
sudo systemctl start nubitd

echo "Installation and service setup complete."
