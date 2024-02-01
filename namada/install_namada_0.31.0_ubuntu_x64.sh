#!/bin/bash
echo "Downloading files......"
wget https://github.com/cometbft/cometbft/releases/download/v0.37.2/cometbft_0.37.2_linux_amd64.tar.gz
tar xvzf cometbft_0.37.2_linux_amd64.tar.gz
sudo cp ./cometbft /usr/local/bin/
chmod +x /usr/local/bin/cometbft
rm -rf cometbft_0.37.2_linux_amd64.tar.gz


wget -O namada-v0.31.0-Linux-x86_64.tar.gz https://github.com/anoma/namada/releases/download/v0.31.0/namada-v0.31.0-Linux-x86_64.tar.gz
tar xvzf namada-v0.31.0-Linux-x86_64.tar.gz
rm namada-v0.31.0-Linux-x86_64.tar.gz
cd namada-v0.31.0-Linux-x86_64
wait
sudo cp ./namada* /usr/local/bin/
namada -V

export CHAIN_ID="shielded-expedition.b40d8e9055"
namada client utils join-network --chain-id $CHAIN_ID
wait

sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=CMT_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
wait
sudo systemctl enable namadad
wait
sudo systemctl start namadad
wait

echo "Show node logs: sudo journalctl -u namadad -f -o cat"



