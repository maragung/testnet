#!/bin/bash

# Memperbarui sistem dan menginstal paket dasar
echo "Memperbarui sistem..."
sudo apt-get update

echo "Menginstal screen..."
sudo apt install -y screen

# Membuat screen baru bernama 'nexus'
screen -S nexus -d -m

# Menginstal dependensi lain yang diperlukan
echo "Menginstal dependensi lainnya..."
sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

# Menginstal protobuf-compiler
sudo apt install -y build-essential protobuf-compiler

# Menginstal Rust
echo "Menginstal Rust..."
sudo curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env

# Menambahkan Rust ke PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Membuat direktori untuk Nexus
mkdir -p "$HOME/.nexus/"

# Meminta input Prover ID
echo "Masukkan Prover ID Anda:"
read prover_id

# Menyimpan Prover ID ke dalam file
echo $prover_id | sudo tee $HOME/.nexus/prover-id > /dev/null

# Menginstal CLI Nexus
echo "Menginstal Nexus CLI..."
sudo curl https://cli.nexus.xyz/install.sh | sh

echo "Instalasi selesai."
