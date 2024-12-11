#!/bin/bash

# Memperbarui repositori dan menginstal dependensi
sudo apt-get update
sudo apt install -y \
    curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf \
    tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils \
    ncdu unzip build-essential protobuf-compiler

# Instalasi Rust
if ! command -v cargo &> /dev/null; then
    echo "Rust tidak ditemukan, menginstal Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust sudah terinstal."
fi

# Menambahkan Rust ke PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Membuat direktori konfigurasi Nexus
NEXUS_DIR="$HOME/.nexus"
mkdir -p "$NEXUS_DIR"

# Meminta input Prover ID
echo "Masukkan Prover ID Anda:"
read -r PROVER_ID

# Menyimpan Prover ID ke file
PROVER_ID_FILE="$NEXUS_DIR/prover-id"
echo "$PROVER_ID" > "$PROVER_ID_FILE"
echo "Prover ID telah disimpan di $PROVER_ID_FILE"

# Mengunduh binary dan memindahkannya ke /usr/local/bin
BINARY_URL="https://github.com/maragung/testnet/raw/refs/heads/main/bin/ubuntu_nx_prover_x86_64"
BINARY_PATH="/usr/local/bin/ubuntu_nx_prover"
echo "Mengunduh binary dari $BINARY_URL..."
curl -L "$BINARY_URL" -o "$BINARY_PATH"
sudo chmod +x "$BINARY_PATH"
echo "Binary telah diunduh dan dipindahkan ke $BINARY_PATH"

# Membuat service systemd
SERVICE_FILE="/etc/systemd/system/nexus-prover.service"
echo "Membuat service systemd untuk Nexus Prover..."
echo "[Unit]
Description=Nexus Prover Service
After=network.target

[Service]
Type=simple
ExecStart=$BINARY_PATH -- beta.orchestrator.nexus.xyz
Restart=on-failure
RestartSec=3
User=$(whoami)

[Install]
WantedBy=multi-user.target" | sudo tee "$SERVICE_FILE"

# Reload dan enable service
sudo systemctl daemon-reload
sudo systemctl enable nexus-prover
sudo systemctl start nexus-prover

# Memberikan pesan selesai
echo "Instalasi dan konfigurasi selesai. Prover ID Anda: $PROVER_ID"
echo "Service Nexus Prover telah dibuat dan berjalan."
