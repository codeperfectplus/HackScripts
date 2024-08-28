#!/bin/bash

# Script for basic server setup on a Linux system
# status: tested
# published by: Deepak Raj
# published on: 2024-08-28

# indian timezone
NEW_USER="admin"
TIMEZONE="Asia/Kolkata"

# Function to update and upgrade the system
update_system() {
    echo "Updating and upgrading the system..."
    sudo apt-get update && sudo apt-get upgrade -y
}

# Function to install basic packages
install_basic_packages() {
    echo "Installing basic packages..."
    sudo apt-get install -y curl wget git vim ufw htop unzip nano
}

# Function to set the timezone
set_timezone() {
    echo "Setting timezone to $TIMEZONE..."
    sudo timedatectl set-timezone $TIMEZONE
}

# Function to add a new user
add_new_user() {
    echo "Adding new user $NEW_USER..."
    sudo adduser --gecos "" $NEW_USER
    sudo usermod -aG sudo $NEW_USER
    echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$NEW_USER
    echo "User $NEW_USER has been created and added to the sudo group."
}

# Main function to run all setup steps
main() {
    update_system
    install_basic_packages
    set_timezone
    # add_new_user
}

echo "Server setup is complete!"
# Run the main function
main
