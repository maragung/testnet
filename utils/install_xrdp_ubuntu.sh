#!/bin/bash

choose_desktop_environment() {
    echo "Choose a desktop environment to install:"
    echo "1) GNOME (Full with Extensions)"
    echo "2) XFCE (Lightweight)"
    echo "3) LXDE (Ultra Lightweight)"
    echo "4) MATE (Full with Tools)"
    echo "5) Cancel"
    printf "\n"
    read -p "Enter your choice [1-5]: " choice

    case "$choice" in
        1)
            selected_desktop="GNOME"
            ;;
        2)
            selected_desktop="XFCE"
            ;;
        3)
            selected_desktop="LXDE"
            ;;
        4)
            selected_desktop="MATE"
            ;;
        5)
            echo "Canceling installation."
            exit 0
            ;;
        *)
            echo "Invalid choice! Please select a valid option."
            choose_desktop_environment
            ;;
    esac
    echo "Selected desktop environment: $selected_desktop"
}

remove_existing_desktops() {
    echo "Removing any previously installed desktop environments..."
    apt purge -y ubuntu-desktop gnome-shell xfce4 lxde lxde-core mate-desktop-environment mate-core lightdm
    apt autoremove -y
}

install_desktop_environment() {
    case "$selected_desktop" in
        GNOME)
            echo "Installing GNOME desktop..."
            apt update && apt install -y ubuntu-desktop gnome-shell gnome-session gnome-terminal gnome-control-center gnome-tweaks
            ;;
        XFCE)
            echo "Installing XFCE desktop..."
            apt update && apt install -y xfce4 xfce4-goodies
            ;;
        LXDE)
            echo "Installing LXDE desktop..."
            apt update && apt install -y lxde lxde-core
            ;;
        MATE)
            echo "Installing MATE desktop..."
            apt update && apt install -y mate-desktop-environment mate-core
            ;;
    esac
}

install_xrdp() {
    echo "Installing XRDP..."
    apt update && apt install -y xrdp
    systemctl enable xrdp
    systemctl restart xrdp
}

configure_xrdp() {
    echo "Configuring XRDP..."
    if [ "$selected_desktop" = "GNOME" ]; then
        echo "export DESKTOP_SESSION=gnome" > ~/.xsession
    elif [ "$selected_desktop" = "XFCE" ]; then
        echo "startxfce4" > ~/.xsession
    elif [ "$selected_desktop" = "LXDE" ]; then
        echo "startlxde" > ~/.xsession
    elif [ "$selected_desktop" = "MATE" ]; then
        echo "mate-session" > ~/.xsession
    fi
    chmod +x ~/.xsession
    systemctl restart xrdp
}

display_details() {
    echo "XRDP and $selected_desktop desktop environment have been successfully installed."
    echo "Connection Details:"
    echo "IP Address: $(hostname -I | awk '{print $1}')"
    echo "Port: 3389"
    echo "To connect, use an RDP client and enter the above IP and port."
}

# Main Execution
choose_desktop_environment
remove_existing_desktops
install_desktop_environment
install_xrdp
configure_xrdp
display_details
