#!/bin/bash

# Make sure you are in the correct directory
cd /etc/systemd/system/

# Check if the 'namadad.service' service file already exists
if [ -f namadad.service ]; then
  echo "Deleting the existing 'namadad.service' service."
  sudo systemctl stop namadad
  sudo systemctl disable namadad
  sudo rm namadad.service
fi

# Get the execution location of 'namada' from the result of 'which namada'
NAMADA_EXEC=$(which namada)

# Add the contents of the 'namadad.service' service file
cat <<EOL > namadad.service
[Unit]
Description=namada
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=CMT_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=$NAMADA_EXEC node ledger run
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd
sudo systemctl daemon-reload

# Enable and start the service
cd
sudo systemctl enable namadad
sudo systemctl start namadad

echo "The 'namadad' service has been recreated and re-enabled."
echo "To restart service: sudo systemctl start namadad"
echo "To checking block status: curl http://127.0.0.1:26657/status | jq"
echo "To view node logs: sudo journalctl -u namadad -f -o cat"
