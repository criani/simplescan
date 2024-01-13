
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
    sudo apt-get install -y libffi-dev libssl-dev
    sudo apt-get install -y python3 python3-pip
    sudo apt-get remove python-configparser
    sudo pip3 install docker-compose
fi

# Pull and run the SimpleScan Docker image
echo "Pulling and running SimpleScan Docker image..."
sudo mkdir -p /opt/simplescan
cd /opt/simplescan
sudo docker pull nextier/simplescan:arm64
sudo docker run -d -p 5000:5000 nextier/simplescan:arm64

echo "SimpleScan is now running on port 5000."
