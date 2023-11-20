sudo apt-get update
sudo apt-get install -y build-essential curl wget jq make gcc chrony git
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo su -c "echo 'fs.file-max = 65536' >> /etc/sysctl.conf"
sudo sysctl -p

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo rm -rf /usr/local/.go
wget -O go1.19.2.linux-amd64.tar.gz https://go.dev/dl/go1.19.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz
sudo cp /usr/local/go /usr/local/.go -r
sudo rm -rf /usr/local/go
rm go1.19.2.linux-amd64.tar.gz

cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/.go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/.go/bin:$HOME/go/bin
EOF
source $HOME/.profile

go version
sleep 3

git clone https://github.com/arkeonetwork/arkeo
cd arkeo
git checkout ab05b124336ace257baa2cac07f7d1bfeed9ac02
make proto-gen install
arkeo version

