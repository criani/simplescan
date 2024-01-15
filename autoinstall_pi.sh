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

# Create directories for scans and reports
echo "Creating directories for scans and reports..."
sudo mkdir -p /opt/simplescan/scans
sudo mkdir -p /opt/simplescan/reports

# Pull the latest SimpleScan Docker image
echo "Pulling the latest SimpleScan Docker image..."
sudo docker pull nextier/simplescan:arm64

# Check if the SimpleScan container is already running, and remove it if it is
container_id=$(sudo docker ps -aqf "name=simplescan")
if [ ! -z "$container_id" ]; then
    echo "Existing SimpleScan container found. Removing it..."
    sudo docker stop "$container_id"
    sudo docker rm "$container_id"
fi

# Run the SimpleScan Docker container with volume bindings for persistence
echo "Running SimpleScan Docker container with persistent volumes..."
sudo docker run -d \
  -p 5000:5000 \
  -v /opt/simplescan/scans:/app/scans \
  -v /opt/simplescan/reports:/app/reports \
  --name simplescan \
  nextier/simplescan:arm64

echo "SimpleScan is now running on port 5000 with persistent storage for scans and reports."

