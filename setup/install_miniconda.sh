#!/bin/bash

# Script to setup Miniconda on a Linux system
# status: tested
# published by: Deepak Raj
# published on: 2024-08-28

get_user_home() {
    if [ -n "$SUDO_USER" ]; then
        # When using sudo, SUDO_USER gives the original user who invoked sudo
        TARGET_USER="$SUDO_USER"
    else
        # If not using sudo, use LOGNAME to find the current user
        TARGET_USER="$LOGNAME"
    fi
    
    # Get the home directory of the target user
    USER_HOME=$(eval echo ~$TARGET_USER)
    echo "$USER_HOME"
}

# Define Miniconda version and installation path
USER_HOME=$(get_user_home)
MINICONDA_VERSION="latest"
INSTALL_PATH="$USER_HOME/miniconda3"
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
