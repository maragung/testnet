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

echo_info "Installing XRDP, XFCE, and additional XFCE panels..."
apt install -y xrdp xfce4 xfce4-goodies xfce4-panel xfce4-dockbarx-plugin xfce4-whiskermenu-plugin xfce4-indicator-plugin xfce4-taskmanager

# Configure XRDP
echo_info "Configuring XRDP to use XFCE..."
cat <<EOF > /etc/xrdp/startwm.sh
#!/bin/bash
exec startxfce4
EOF
chmod +x /etc/xrdp/startwm.sh

# Restart XRDP service
systemctl enable xrdp
systemctl restart xrdp

echo_success "XRDP and XFCE have been successfully installed and configured."

# Retrieve IP and port information
echo_info "Retrieving IP and port details..."
IP=$(hostname -I | awk '{print $1}')
PORT=3389

# Display information
echo -e "\n=== XRDP Server Information ==="
echo -e "IP Address: $IP"
echo -e "Port: $PORT"
echo -e "XRDP Service: $(systemctl is-active xrdp)"

# Function to manage desktop services
manage_service() {
  echo -e "\nSelect an option for desktop services:"
  echo "1) Start XRDP"
  echo "2) Restart XRDP"
  echo "3) Stop XRDP"
  echo "4) Exit"
  read -p "Choose an option (1-4): " choice

  case $choice in
    1)
      systemctl start xrdp
      echo_success "XRDP started."
      ;;
    2)
      systemctl restart xrdp
      echo_success "XRDP restarted."
      ;;
    3)
      systemctl stop xrdp
      echo_success "XRDP stopped."
      ;;
    4)
      echo_info "Exiting."
      exit 0
      ;;
    *)
      echo_error "Invalid option."
      ;;
  esac
}

# Offer service management
while true; do
  manage_service
done
