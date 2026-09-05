#!/bin/bash
set -e

echo "Checking Docker installation..."

if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    
    # Update package manager
    sudo apt-get update -y
    
    # Install dependencies
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $(whoami)
    
    echo "Docker installed successfully"
else
    echo "Docker is already installed: $(docker --version)"
fi

# Ensure docker daemon is running
sudo systemctl start docker || true
sudo systemctl enable docker || true

echo "Docker setup complete"
