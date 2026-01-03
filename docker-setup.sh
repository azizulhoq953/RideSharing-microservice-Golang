#!/bin/bash

# Quick Docker Hub Setup Script

echo "=========================================="
echo "Docker Hub Setup for Ride-Sharing Project"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first."
    echo "   Download: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo "✓ Docker is installed: $(docker --version)"
echo ""

# Check if logged in to Docker
if ! docker info | grep -q "Username:"; then
    echo "⚠️  Not logged in to Docker Hub"
    echo "Please run: docker login"
    echo ""
    read -p "Would you like to login now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    fi
fi

echo ""
echo "=========================================="
echo "Ready to build and push images!"
echo "=========================================="
echo ""
echo "Usage: ./build-and-push.sh <docker-hub-username>"
echo ""
echo "Example:"
echo "  ./build-and-push.sh azizul"
echo ""
echo "This will:"
echo "  1. Compile all Go services"
echo "  2. Build Docker images"
echo "  3. Push to Docker Hub"
echo ""
echo "Your images will be available at:"
echo "  - docker.io/<username>/api-gateway:latest"
echo "  - docker.io/<username>/trip-service:latest"
echo "  - docker.io/<username>/driver-service:latest"
echo "  - docker.io/<username>/payment-service:latest"
echo "  - docker.io/<username>/web:latest"
echo ""
