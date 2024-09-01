#!/bin/bash

# Script to setup Miniconda on a Linux system
# status: tested
# published by: Deepak Raj
# published on: 2024-08-28

# run script as root use
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

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
INSTALL_PATH="$USER_HOME/miniconda3"
MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
TMP_INSTALLER="/tmp/$MINICONDA_INSTALLER"
MINICONDA_PAGE_URL="https://docs.anaconda.com/miniconda/"

# Function to extract the checksum from the documentation page
extract_checksum() {
    echo "Downloading Miniconda documentation page..."

    wget -q "$MINICONDA_PAGE_URL" -O miniconda_page.html

    if [ ! -f "miniconda_page.html" ]; then
        echo "Failed to download Miniconda documentation page."
        return 1
    fi

    echo "Extracting checksum for $MINICONDA_INSTALLER..."
    # Look for the specific section where the installer and checksum are mentioned
    CHECKSUM=$(grep -A 1 "$MINICONDA_INSTALLER" miniconda_page.html | grep -oP '(?<=<span class="pre">)[a-f0-9]{64}(?=</span>)')
    # save the checksum to a file

    rm miniconda_page.html

    if [ -z "$CHECKSUM" ]; then
        echo "Checksum for $MINICONDA_INSTALLER not found on the page."
        return 1
    fi
}

# check if tmp_installers file exists
if [ -f "$TMP_INSTALLER" ]; then
    echo "Miniconda installer already exists in /tmp. Skipping download."
else
    echo "Downloading Miniconda installer..."
    wget https://repo.anaconda.com/miniconda/$MINICONDA_INSTALLER -O /tmp/$MINICONDA_INSTALLER
fi

echo "Verifying Miniconda installer..."

# sumcheck of $TMP_INSTALLER
sumcheck=$(sha256sum $TMP_INSTALLER | awk '{print $1}')
# compare $sumcheck with the checksum from the documentation page
extract_checksum
echo "checksum of downloaded file: $sumcheck"
echo "checksum from documentation page: $CHECKSUM"
if [ "$sumcheck" != "$CHECKSUM" ]; then
    echo "Checksum verification failed. Exiting..."
    exit 1
fi

echo "Checksum verification successful."
echo "Running Miniconda installer..."

# check if install path exists
if [ -d "$INSTALL_PATH" ]; then
    echo "Miniconda is already installed in $INSTALL_PATH. Exiting..."
    echo "Do you want to update Miniconda? (y/n)"
    read update
    if [ "$update" == "n" ]; then
        exit 0
    fi
    bash /tmp/$MINICONDA_INSTALLER -b -p $INSTALL_PATH -u
fi
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
