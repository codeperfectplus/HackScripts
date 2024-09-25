#!/bin/bash

# Script to install Visual Studio Code on a Linux system
# status: tested
# published by: Deepak Raj
# published on: 2024-08-28

# Exit immediately if a command exits with a non-zero status
set -e

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

USERNAME=$(get_user_name)

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install prerequisites
echo "Installing prerequisites..."
sudo apt-get install -y wget gpg

# Add Microsoft’s GPG key
echo "Adding Microsoft GPG key..."
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg

# Add VS Code repository
echo "Adding VS Code repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

# Update package lists again with the new repository
echo "Updating package lists with VS Code repository..."
sudo apt-get update

# Install VS Code
echo "Installing VS Code..."
sudo apt-get install -y code

# Verify installation
echo "Verifying VS Code installation..."


sudo -u $USERNAME code --version

echo "Visual Studio Code installation completed successfully."
echo "Installed version details:"
sudo -u $USERNAME code --version
echo "You can start Visual Studio Code by running 'code' from the terminal."
