#!/bin/bash

echo -e "\033[32m"
cat << "EOF"
                  _                         _            
  __   __    ____ (_)__  ____   ____  _   _ (_)__    ____ 
 (__)_(__)  (____)(____)(____) (____)(_) (_)(____)  (____)
(_) (_) (_)( )_( )(_)  ( )_( )( )_(_)(_)_(_)(_) (_)( )_(_)
(_) (_) (_) (__)_)(_)   (__)_) (____) (___) (_) (_) (____)
                              (_)_(_)              (_)_(_)
                               (___)                (___)
EOF
echo -e "\033[0m"

install_dependencies() {
    echo "Installing dependencies..."
    apt-get install curl wget jq
    wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb
    sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb

    wget https://mirrors.edge.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb
    sudo dpkg -i libffi6_3.2.1-8_amd64.deb

    wget http://ftp.de.debian.org/debian/pool/main/p/procps/libprocps7_3.3.15-2_amd64.deb
    sudo dpkg -i libprocps7_3.3.15-2_amd64.deb

    rm *.deb
}

install_mina() {
    echo "Installing Mina..."
    # Get the codename from LSB (Linux Standard Base)
    LSB_CODENAME=$(lsb_release -cs 2>/dev/null)
    
    # If LSB_CODENAME is not available or doesn't match the desired codenames, use "focal" as the default
    if [ -z "$LSB_CODENAME" ] || [ "$LSB_CODENAME" != "focal" ] && [ "$LSB_CODENAME" != "buster" ] && [ "$LSB_CODENAME" != "bullseye" ]; then
      CODENAME="focal"
    else
      CODENAME="$LSB_CODENAME"
    fi

    # Update the repository with the appropriate codename
    echo "Using codename: $CODENAME"
    echo "Removing sources.list.d files for Mina..."
    sudo rm /etc/apt/sources.list.d/mina*.list
    echo "Adding repository for Mina with codename: $CODENAME"
    echo "deb [trusted=yes] http://packages.o1test.net/ $CODENAME rampup" | sudo tee "/etc/apt/sources.list.d/mina-rampup.list"
    sudo apt-get update
    sudo apt-get install -y mina-berkeley=2.0.0rampup5-55b7818
    which mina
    mina version
    mkdir ~/keys -p
    chmod 700 ~/keys
    echo "Mina installed successfully."
}


install_dependencies
install_mina
