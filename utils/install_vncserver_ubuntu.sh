#!/bin/bash

# Function to display colored messages
echo_info() {
  echo -e "\e[34m[INFO]\e[0m $1"
}

echo_success() {
  echo -e "\e[32m[SUCCESS]\e[0m $1"
}

echo_error() {
  echo -e "\e[31m[ERROR]\e[0m $1"
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo_error "This script must be run as root."
  exit 1
fi

# Update system and install required packages
echo_info "Updating system packages..."
apt update && apt upgrade -y

echo_info "Installing VNC Server, XFCE, and additional panels..."
apt install -y xfce4 xfce4-goodies xfce4-dockbarx-plugin xfce4-whiskermenu-plugin xfce4-taskmanager xfce4-battery-plugin xfce4-datetime-plugin xfce4-screenshooter tightvncserver

if [ $? -ne 0 ]; then
  echo_error "Failed to install some packages. Check if they are available in the repository."
  exit 1
fi

# Configure VNC
echo_info "Configuring VNC Server..."
mkdir -p ~/.vnc
cat <<EOF > ~/.vnc/xstartup
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF
chmod +x ~/.vnc/xstartup

# Set up password for VNC Server
echo_info "Please enter a password for VNC Server."
vncpasswd

# Create a systemd service for VNC Server
echo_info "Creating systemd service for VNC Server..."
cat <<EOF > /etc/systemd/system/vncserver@.service
[Unit]
Description=Start TightVNC server at user login
After=syslog.target network.target

[Service]
Type=forking
User=$USER
PAMName=login
PIDFile=/home/$USER/.vnc/%H:%i.pid
ExecStart=/usr/bin/vncserver :%i -geometry 1366x768 -depth 24
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
echo_info "Reloading systemd and enabling VNC Server service..."
systemctl daemon-reload
systemctl enable vncserver@1.service
systemctl start vncserver@1.service

if [ $? -ne 0 ]; then
  echo_error "Failed to start VNC Server service. Check logs for details."
  journalctl -xe | grep vncserver
  exit 1
fi

echo_success "XFCE and VNC Server have been successfully installed and configured."

# Retrieve IP and port details
echo_info "Retrieving IP and port details..."
IP=$(hostname -I | awk '{print $1}')
PORT_VNC=5901

# Display information
echo -e "\n=== Server Information ==="
echo -e "IP Address: $IP"
echo -e "VNC Port: $PORT_VNC"

echo_success "Setup complete. Use the above IP and port to access the server via VNC."

# Function to manage the desktop service
manage_service() {
  echo -e "\nSelect an option for the VNC Server service:"
  echo "1) Start VNC Server"
  echo "2) Restart VNC Server"
  echo "3) Stop VNC Server"
  echo "4) Status of VNC Server"
  echo "5) Exit"
  read -p "Choose an option (1-5): " choice

  case $choice in
    1)
      systemctl start vncserver@1.service
      if [ $? -eq 0 ]; then
        echo_success "VNC Server service started successfully on display :1."
      else
        echo_error "Failed to start VNC Server service. Check logs for details."
      fi
      ;;
    2)
      systemctl restart vncserver@1.service
      if [ $? -eq 0 ]; then
        echo_success "VNC Server service restarted successfully on display :1."
      else
        echo_error "Failed to restart VNC Server service. Check logs for details."
      fi
      ;;
    3)
      systemctl stop vncserver@1.service
      if [ $? -eq 0 ]; then
        echo_success "VNC Server service stopped successfully."
      else
        echo_error "Failed to stop VNC Server service. Check logs for details."
      fi
      ;;
    4)
      systemctl status vncserver@1.service
      ;;
    5)
      echo_info "Exiting."
      exit 0
      ;;
    *)
      echo_error "Invalid option."
      ;;
  esac
}

# Offer service management options
while true; do
  manage_service
done
