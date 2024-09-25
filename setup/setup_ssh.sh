#!/bin/bash

# setup open ssh server on ubuntu
# status: tested
# published by: Deepak Raj
# published on: 2024-08-28

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install OpenSSH Server
echo "Installing OpenSSH Server..."
apt-get update
apt-get install -y openssh-server

# Enable and start the SSH service
echo "Enabling and starting the SSH service..."
systemctl enable ssh
systemctl start ssh

# Install UFW (Uncomplicated Firewall)
echo "Installing UFW (Uncomplicated Firewall)..."
apt-get install -y ufw

# Allow SSH through the firewall
echo "Allowing SSH traffic on port 22..."
ufw allow 22/tcp

# Enable the firewall
echo "Enabling the firewall..."
ufw enable

# Get the server's IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')
if [ -z "$IP_ADDRESS" ]; then
  echo "Could not retrieve IP address. Please check your network settings."
  exit 1
fi

# function to get the user name
get_user_name() {
    if [ "$(whoami)" = "root" ]; then
        LOGNAME_USER=$(logname 2>/dev/null) # Redirect any error output to /dev/null
        if [ $? -ne 0 ]; then               # Check if the exit status of the last command is not 0
            USER_NAME=$(cat /etc/passwd | grep '/home' | cut -d: -f1 | tail -n 1)
        else
            USER_NAME=$LOGNAME_USER
        fi
    else
        USER_NAME=$(whoami)
    fi
    echo "$USER_NAME"
}

# Get the current username
USERNAME=$(get_user_name)

# Display the login information
echo "====================================="
echo "OpenSSH Server has been installed and configured."
echo "You can access this server using the following information:"
echo ""
echo "IP Address: $IP_ADDRESS"
echo "Username:   $USERNAME"
echo ""
echo "To log in from another machine, use the following command:"
echo "ssh $USERNAME@$IP_ADDRESS"
echo "====================================="

# do ssh to test the connection
echo "Do you want to test the SSH connection now? (y/n)"
read -r response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "SSH connection test skipped."
  exit 0
fi

echo "Testing SSH connection..."
ssh $USERNAME@$IP_ADDRESS "echo 'SSH connection successful'"
echo "SSH connection test successful."
