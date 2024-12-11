#!/bin/bash

# Memperbarui dan menginstal paket yang dibutuhkan
echo "Memperbarui daftar paket..."
sudo apt-get update

echo "Menginstal screen..."
sudo apt install screen -y

# Membuat screen baru bernama nexus
screen -S nexus -d -m

# Memasang paket yang diperlukan di dalam screen
screen -S nexus -X stuff "sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y\n"
screen -S nexus -X stuff "sudo apt install build-essential protobuf-compiler -y\n"

# Menginstal Rust
screen -S nexus -X stuff "sudo curl https://sh.rustup.rs -sSf | sh\n"
screen -S nexus -X stuff "source \$HOME/.cargo/env\n"
screen -S nexus -X stuff "export PATH=\"\$HOME/.cargo/bin:\$PATH\"\n"

# Membuat direktori untuk Nexus
screen -S nexus -X stuff "mkdir -p \$HOME/.nexus/\n"

# Meminta input untuk Prover ID
echo "Masukkan Prover ID yang ingin disimpan:"
read prover_id

# Menyimpan Prover ID ke file
screen -S nexus -X stuff "echo \"$prover_id\" > \$HOME/.nexus/prover-id\n"
screen -S nexus -X stuff "nano \$HOME/.nexus/prover-id\n"

# Menginstal CLI Nexus
screen -S nexus -X stuff "sudo curl https://cli.nexus.xyz/install.sh | sh\n"

echo "Proses instalasi selesai. Screen 'nexus' sedang berjalan, dan Prover ID telah disimpan."
