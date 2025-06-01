#!/bin/bash

# Script to set up Miniconda on a Linux system
# Status: Tested
# Published by: Deepak Raj
# Published on: 2024-08-28

# Function to determine the home directory of the target user
get_user_name() {
    if [ "$(whoami)" = "root" ]; then
        LOGNAME_USER=$(logname 2>/dev/null) # Redirect any error output to /dev/null
        if [ $? -ne 0 ]; then               # Check if the exit status of the last command is not 0
            echo "No login name found. Using fallback method."
            # use head -n 1 for native linux. tail -n 1 works with wsl.
            USER_NAME=$(cat /etc/passwd | grep '/home' | cut -d: -f1 | tail -n 1)
        else
            USER_NAME=$LOGNAME_USER
        fi
    else
        USER_NAME=$(whoami)
    fi
    echo "$USER_NAME"
}

USER_NAME=$(get_user_name)
USER_HOME="/home/$USER_NAME"
echo "User home directory: $USER_HOME"
INSTALL_PATH="$USER_HOME/miniconda3"
MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
TMP_INSTALLER="/tmp/$MINICONDA_INSTALLER"
MINICONDA_PAGE_URL="https://docs.anaconda.com/miniconda/"

# Download Miniconda installer if it doesn't already exist
if [ -f "$TMP_INSTALLER" ]; then
    echo "Miniconda installer already exists in /tmp. Skipping download."
else
    echo "Downloading Miniconda installer..."
    wget https://repo.anaconda.com/miniconda/$MINICONDA_INSTALLER -O $TMP_INSTALLER
fi

# Check if Miniconda is already installed
echo $INSTALL_PATH

if [ -d "$INSTALL_PATH" ]; then
    echo "Miniconda is already installed at $INSTALL_PATH."
    read -p "Do you want to update Miniconda? (y/n): " update
    if [ "$update" != "y" ]; then
        echo "Exiting..."
        exit 0
    fi
    bash $TMP_INSTALLER -b -p $INSTALL_PATH -u
else
    # Run the Miniconda installer
    echo "Running Miniconda installer..."
    bash $TMP_INSTALLER -b -p $INSTALL_PATH
fi

# Initialize Miniconda
echo "Initializing Miniconda..."
$INSTALL_PATH/bin/conda init

# Clean up the installer
echo "Cleaning up..."
rm $TMP_INSTALLER

# Optional: Update Conda to the latest version
echo "Updating Conda..."
$INSTALL_PATH/bin/conda update -n base -c defaults conda -y

source ~/.bashrc

# Display final message
echo "Miniconda installation completed!"
echo "Miniconda is installed at $INSTALL_PATH"
