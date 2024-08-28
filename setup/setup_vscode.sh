#!/bin/bash

# Script to install Visual Studio Code on a Linux system
# status: tested
# published by: Deepak Raj
# published on: 2024-08-28

# Exit immediately if a command exits with a non-zero status
set -e

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install prerequisites
echo "Installing prerequisites..."
sudo apt-get install -y wget gpg

# Add Microsoft’s GPG key
echo "Adding Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg

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
code --version

echo "Visual Studio Code installation completed."
