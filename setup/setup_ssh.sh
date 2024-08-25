  #!/bin/bash

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

  # Get the current username
  USERNAME=$(whoami)

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
