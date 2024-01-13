
#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# Check for Docker and install it if not found
if ! command_exists docker; then
    echo "Docker is not installed. Installing Docker..."
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Check for Docker Compose and install it if not found
if ! command_exists docker-compose; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Pull and run the SimpleScan Docker image
echo "Pulling and running SimpleScan Docker image..."
sudo mkdir -p /opt/simplescan
cd /opt/simplescan
sudo docker pull nextier/simplescan:latest
sudo docker run -d -p 5000:5000 nextier/simplescan:latest

echo "SimpleScan is now running on port 5000."
