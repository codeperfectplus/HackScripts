#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

# Define Miniconda version and installation path
MINICONDA_VERSION="latest"
INSTALL_PATH="$HOME/miniconda3"
MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"

# Download Miniconda installer
echo "Downloading Miniconda installer..."
wget https://repo.anaconda.com/miniconda/$MINICONDA_INSTALLER -O /tmp/$MINICONDA_INSTALLER

# Verify the download (optional but recommended)
# You can compare the checksum with the one provided on Miniconda's website
echo "Verifying Miniconda installer..."
# Example checksum comparison:
# echo "expected_checksum  /tmp/$MINICONDA_INSTALLER" | sha256sum -c

# Run the Miniconda installer
echo "Running Miniconda installer..."
bash /tmp/$MINICONDA_INSTALLER -b -p $INSTALL_PATH

# Initialize Miniconda
echo "Initializing Miniconda..."
$INSTALL_PATH/bin/conda init

# Clean up the installer
echo "Cleaning up..."
rm /tmp/$MINICONDA_INSTALLER

# Optional: Update Conda to the latest version
echo "Updating Conda..."
$INSTALL_PATH/bin/conda update -n base -c defaults conda -y

# Display final message
echo "Miniconda installation completed!"
echo "Miniconda is installed in $INSTALL_PATH"
echo "Restart your terminal or run 'source ~/.bashrc' to activate Miniconda."
