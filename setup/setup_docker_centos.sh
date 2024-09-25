#!/bin/bash

# Script to install Docker and Docker Compose on centos system
# status: tested
# published by: Deepak Raj
# published on: 2024-09-25

# Exit script on any error
set -e

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi


echo "Updating system packages..."
yum update -y

echo "Installing required packages for Docker..."
yum install -y yum-utils device-mapper-persistent-data lvm2

echo "Adding Docker's official repository..."
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "Installing Docker CE (Community Edition)..."
yum install -y docker-ce docker-ce-cli containerd.io

echo "Starting Docker service..."
systemctl start docker

echo "Enabling Docker to start on boot..."
systemctl enable docker

echo "Verifying Docker installation..."
docker --version

echo "Running Docker Hello World test..."
docker run hello-world

echo "Docker has been successfully installed and verified!"

usermod -aG docker $(whoami)
echo "User added to Docker group. Please log out and log back in for changes to take effect."

echo "Docker installation complete."
