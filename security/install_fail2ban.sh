#!/bin/bash

# Script to install and configure fail2ban on Ubuntu

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo."
  exit 1
fi

# Update package lists
echo "Updating package lists..."
apt-get update -y

# Install fail2ban
echo "Installing fail2ban..."
apt-get install -y fail2ban

# Configure fail2ban (basic setup)
echo "Configuring fail2ban..."

# Create a local configuration file to override default settings
# This prevents changes from being overwritten during package updates
cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
# Ban hosts for 10 minutes
bantime = 10m

# Find hosts that fail 5 times
maxretry = 5

# Ignore IP addresses (e.g., for local network)
ignoreip = 127.0.0.1/8

# Enable common jail configurations
[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s

[apache-auth]
enabled = true
port = http,https
logpath = %(apache_error_log)s

[nginx-http-auth]
enabled = true
port = http,https
logpath = %(nginx_error_log)s

EOF

# Restart fail2ban to apply the new configuration
echo "Restarting fail2ban..."
systemctl restart fail2ban

# Enable fail2ban to start on boot
echo "Enabling fail2ban to start on boot..."
systemctl enable fail2ban

# Display status of fail2ban
echo "Checking the status of fail2ban..."
systemctl status fail2ban

# Display final message
echo "Fail2ban installation and configuration completed!"
echo "Fail2ban is now installed and running. It will help protect your server from brute-force attacks."
