#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# Check for Docker and install it if not found
if ! command_exists docker; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Check for Docker Compose and install it if not found
if ! command_exists docker-compose; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create a directory for SimpleScan and enter it
sudo mkdir -p /opt/simplescan
cd /opt/simplescan

# Download the docker-compose.yml file from the GitHub repository
echo "Downloading docker-compose.yml from GitHub..."
sudo curl -L "https://raw.githubusercontent.com/criani/simplescan/main/docker-compose.yml" -o docker-compose.yml

# Run Docker Compose to start the SimpleScan container
echo "Starting SimpleScan using Docker Compose..."
sudo docker-compose up -d

echo "SimpleScan is now running on port 5000."


