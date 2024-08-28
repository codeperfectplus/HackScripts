#!/bin/bash

# Script to setup Redis server on a Linux system
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
sudo apt-get install -y wget gnupg

# Add PostgreSQL APT repository
echo "Adding PostgreSQL APT repository..."
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /usr/share/keyrings/pgdg-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/pgdg-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Update package lists again with the new repository
echo "Updating package lists with PostgreSQL repository..."
sudo apt-get update

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

# Install pgAdmin4
echo "Installing pgAdmin4..."
curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/pgadmin-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/pgadmin-archive-keyring.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/ $(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list
sudo apt-get update
sudo apt-get install -y pgadmin4

# Optionally, run the web version setup for pgAdmin
echo "Setting up pgAdmin4 web..."
sudo /usr/pgadmin4/bin/setup-web.sh

# Enable and start PostgreSQL service
echo "Enabling and starting PostgreSQL service..."
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create a new PostgreSQL user
read -p "Enter the new PostgreSQL username: " pg_username
read -s -p "Enter the password for the new PostgreSQL user: " pg_password
echo

echo "Creating PostgreSQL user $pg_username..."
sudo -u postgres psql -c "CREATE USER $pg_username WITH PASSWORD '$pg_password';"

# Optionally, create a new database owned by the new user
read -p "Would you like to create a new database for this user? (y/n): " create_db

if [[ $create_db == "y" || $create_db == "Y" ]]; then
    read -p "Enter the new database name: " db_name
    sudo -u postgres psql -c "CREATE DATABASE $db_name OWNER $pg_username;"
    echo "Database $db_name created and owned by $pg_username."
fi

echo "PostgreSQL and pgAdmin installation and user setup completed."
