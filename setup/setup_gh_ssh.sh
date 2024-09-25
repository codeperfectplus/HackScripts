#!/bin/bash

# Script to setup SSH keys for multiple GitHub accounts
# status: tested
# published by: Deepak Raj
# published on: 2024-08-29

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if ssh-keygen is available
if ! command_exists ssh-keygen; then
    echo "ssh-keygen is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y openssh-client
fi

# Check if ssh-agent is running
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
    echo "Starting ssh-agent..."
    eval "$(ssh-agent -s)"
fi

# Function to generate SSH key for an account
generate_ssh_key() {
    local email=$1
    local key_name=$2
    local key_file="$HOME/.ssh/id_rsa_$key_name"

    echo "Generating SSH key for $email..."
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_file" -N ""

    # Set permissions for private and public keys
    chmod 600 "$key_file"
    chmod 644 "${key_file}.pub"

    ssh-add "$key_file"
    echo "SSH key generated and added to the agent for $email."
}

# Add SSH keys for multiple accounts
while true; do
    read -p "Enter your GitHub email address (or press Enter to finish): " email
    if [ -z "$email" ]; then
        break
    fi

    # Extract the part before the @ symbol
    key_name=$(echo "$email" | cut -d '@' -f 1)
    generate_ssh_key "$email" "$key_name"

    echo "Your SSH public key for $email is:"
    cat "$HOME/.ssh/id_rsa_$key_name.pub"

    echo "Please add the above SSH public key to your GitHub account."
    echo "You can add the key by visiting the following link:"
    echo "https://github.com/settings/keys"
done

# Create or update SSH config file for multiple accounts
echo "Creating/updating SSH config file..."
ssh_config="$HOME/.ssh/config"
touch "$ssh_config"
chmod 600 "$ssh_config"

for key_file in ~/.ssh/id_rsa_*; do
    if [[ -f "$key_file" && "$key_file" != ~/.ssh/id_rsa ]]; then
        key_name=$(basename "$key_file" | sed 's/id_rsa_//')
        echo "Host github-$key_name" >> "$ssh_config"
        echo "    HostName github.com" >> "$ssh_config"
        echo "    User git" >> "$ssh_config"
        echo "    IdentityFile $key_file" >> "$ssh_config"
        echo "" >> "$ssh_config"
    fi
done

echo "SSH config file created/updated."

echo "SSH key setup script completed."
