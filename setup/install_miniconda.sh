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
INSTALL_PATH="$USER_HOME/miniconda3"
MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
TMP_INSTALLER="/tmp/$MINICONDA_INSTALLER"
MINICONDA_PAGE_URL="https://docs.anaconda.com/miniconda/"
CHECKSUM_FILE=$MINICONDA_INSTALLER.sha256


# Function to extract the checksum from the documentation page
extract_checksum() {
    echo "Downloading Miniconda documentation page..."

    # if checksum file exists and is not older than 1 day, read the checksum from the file
    if [ -f "$CHECKSUM_FILE" ] && [ $(find "$CHECKSUM_FILE" -mtime -1) ]; then
        echo "Checksum file already exists and is not older than 1 day. Reading checksum from file..."
        CHECKSUM=$(cat "$CHECKSUM_FILE")
        echo "$CHECKSUM"
        return 0
    fi

    wget -q "$MINICONDA_PAGE_URL" -O miniconda_page.html

    if [ ! -f "miniconda_page.html" ]; then
        echo "Failed to download Miniconda documentation page."
        return 1
    fi

    echo "Extracting checksum for $MINICONDA_INSTALLER..."
    # Look for the specific section where the installer and checksum are mentioned
    CHECKSUM=$(grep -A 1 "$MINICONDA_INSTALLER" miniconda_page.html | grep -oP '(?<=<span class="pre">)[a-f0-9]{64}(?=</span>)')
    # save the checksum to a file
    echo "$CHECKSUM" > "$CHECKSUM_FILE"

    rm miniconda_page.html

    if [ -z "$CHECKSUM" ]; then
        echo "Checksum for $MINICONDA_INSTALLER not found on the page."
        return 1
    fi

    echo "$CHECKSUM"
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
if [ "$sumcheck" != "$CHECKSUM" ]; then
    echo "Checksum verification failed. Exiting..."
    exit 1
fi

echo "Checksum verification successful."
echo "Running Miniconda installer..."


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
