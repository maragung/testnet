wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

wget https://github.com/cometbft/cometbft/releases/download/v0.37.2/cometbft_0.37.2_linux_amd64.tar.gz
tar xvzf cometbft_0.37.2_linux_amd64.tar.gz
sudo cp ./cometbft /usr/local/bin/
chmod +x /usr/local/bin/cometbft
rm -rf cometbft_0.37.2_linux_amd64.tar.gz

wget -O namada-v0.28.1-Linux-x86_64.tar.gz https://github.com/anoma/namada/releases/download/v0.28.1/namada-v0.28.1-Linux-x86_64.tar.gz
tar xvzf namada-v0.28.1-Linux-x86_64.tar.gz
rm -rf namada-v0.28.1-Linux-x86_64.tar.gz
cd namada-v0.28.1-Linux-x86_64
sudo cp ./namada* /usr/local/bin/
namada -V

