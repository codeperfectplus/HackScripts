#!/bin/bash

# Script to create a new Conda environment with the latest Python version

# Check if the script is run with an argument for the environment name
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <env_name>"
  exit 1
fi

# Get the environment name from the command-line argument
ENV_NAME="$1"

USER_NAME=$(whoami)

# Define potential Conda installation paths
MINICONDA_PATH="/home/$USER_NAME/miniconda3"
ANACONDA_PATH="/home/$USER_NAME/anaconda3"

# Function to initialize Conda
initialize_conda() {
  local conda_base="$1"
  if [ -d "$conda_base" ]; then
    echo "Initializing Conda from $conda_base..."
    . "$conda_base/etc/profile.d/conda.sh"
    return 0
  else
    return 1
  fi
}

# Check and initialize Conda from Miniconda or Anaconda
if initialize_conda "$MINICONDA_PATH"; then
  CONDA_PATH="$MINICONDA_PATH"
elif initialize_conda "$ANACONDA_PATH"; then
  CONDA_PATH="$ANACONDA_PATH"
else
  echo "Neither Miniconda nor Anaconda found in the defined paths."
  exit 1
fi

# Get the latest Python version available in Conda
echo "Fetching the latest Python version..."
LATEST_PYTHON_VERSION=$(conda search python | grep "python " | awk '{print $2}' | sort -V | tail -n 1)

if [ -z "$LATEST_PYTHON_VERSION" ]; then
  echo "Failed to retrieve the latest Python version. Please check your Conda configuration."
  exit 1
fi

# Create the Conda environment with the latest Python version
echo "Creating Conda environment '$ENV_NAME' with Python $LATEST_PYTHON_VERSION..."
conda create -y -n "$ENV_NAME" python="$LATEST_PYTHON_VERSION"

# Activate the new environment
echo "Activating the new environment..."
conda activate "$ENV_NAME"

# Display the Python version in the new environment
echo "Python version in the new environment:"
python --version

# Display final message
echo "Conda environment '$ENV_NAME' created and activated with Python $LATEST_PYTHON_VERSION."

# Provide instructions for activating the environment
echo "To activate this environment in the future, use:"
echo "conda activate $ENV_NAME"
