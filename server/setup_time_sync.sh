#!/bin/bash

# This script sets up NTP or systemd-timesyncd on Ubuntu
# status: tested
# published by: Deepak Raj
# published on: 2024-08-28

# Function to install and configure NTP
install_ntp() {
    echo "Installing and configuring NTP..."

    # Update package list
    sudo apt-get update
    
    # Install NTP
    sudo apt-get install -y ntp
    
    # Backup existing configuration if present
    if [ -f /etc/ntp.conf ]; then
        sudo cp /etc/ntp.conf /etc/ntp.conf.backup
    fi
    
    # Configure NTP servers
    sudo tee /etc/ntp.conf > /dev/null <<EOL
# Use public servers from the pool
server 0.ubuntubook.org iburst
server 1.ubuntubook.org iburst
server 2.ubuntubook.org iburst
server 3.ubuntubook.org iburst

# Use Ubuntu's NTP server
server ntp.ubuntu.com iburst

# Enable NTP
driftfile /var/lib/ntp/ntp.drift
EOL
    
    # Restart NTP service
    sudo systemctl restart ntp
    
    # Enable NTP to start on boot
    sudo systemctl enable ntp
    
    echo "NTP installation and configuration complete."
}

# Function to install and configure systemd-timesyncd
install_timesyncd() {
    echo "Installing and configuring systemd-timesyncd..."

    # Update package list
    sudo apt-get update
    
    # Install systemd-timesyncd
    sudo apt-get install -y systemd-timesyncd
    
    # Backup existing configuration if present
    if [ -f /etc/systemd/timesyncd.conf ]; then
        sudo cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.backup
    fi
    
    # Configure NTP servers
    sudo tee /etc/systemd/timesyncd.conf > /dev/null <<EOL
[Time]
NTP=0.ubuntubook.org 1.ubuntubook.org 2.ubuntubook.org 3.ubuntubook.org
FallbackNTP=ntp.ubuntu.com
EOL
    
    # Restart systemd-timesyncd service
    sudo systemctl restart systemd-timesyncd
    
    # Enable systemd-timesyncd to start on boot
    sudo systemctl enable systemd-timesyncd
    
    echo "systemd-timesyncd installation and configuration complete."
}

# Function to check if the script is run as root
check_root() {
    if [ "$(id -u)" -ne "0" ]; then
        echo "This script must be run as root. Use sudo."
        exit 1
    fi
}

# Function to show usage
usage() {
    echo "Usage: $0 [ntp|timesyncd]"
    echo "  ntp       - Install and configure NTP"
    echo "  timesyncd - Install and configure systemd-timesyncd"
    exit 1
}

# Check if script is run as root
check_root

# Check if correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    usage
fi

# Install and configure based on the argument
case "$1" in
    ntp)
        install_ntp
        ;;
    timesyncd)
        install_timesyncd
        ;;
    *)
        usage
        ;;
esac
