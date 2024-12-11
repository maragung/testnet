#!/bin/bash

# Memperbarui dan menginstal paket yang dibutuhkan
echo "Memperbarui daftar paket..."
sudo apt-get update

echo "Menginstal screen..."
sudo apt install screen -y

# Membuat screen baru bernama nexus
echo "Membuat screen bernama 'nexus' dan masuk ke dalamnya..."
screen -S nexus

# Di dalam screen, eksekusi perintah berikut
echo "Menginstal paket yang diperlukan di dalam screen..."
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y
sudo apt install build-essential protobuf-compiler -y

# Menginstal Rust
echo "Menginstal Rust..."
sudo curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"

# Membuat direktori untuk Nexus
mkdir -p "$HOME/.nexus/"

# Meminta input untuk Prover ID
echo "Masukkan Prover ID yang ingin disimpan:"
read prover_id

# Menyimpan Prover ID ke file
echo "$prover_id" > $HOME/.nexus/prover-id

# Menjalankan editor untuk Prover ID
nano $HOME/.nexus/prover-id

# Menginstal CLI Nexus
echo "Menginstal Nexus CLI..."
sudo curl https://cli.nexus.xyz/install.sh | sh

echo "Instalasi selesai. Anda telah berada di dalam sesi screen 'nexus'."
echo "Gunakan perintah 'exit' untuk keluar dari sesi screen dan kembali ke terminal utama."
