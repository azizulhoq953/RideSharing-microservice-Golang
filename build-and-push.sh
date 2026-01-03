#!/bin/bash

# Build and Push Docker Images to Docker Hub
# Usage: ./build-and-push.sh <docker-hub-username>

set -e

DOCKER_HUB_USERNAME=${1:-$(whoami)}
REGISTRY="${DOCKER_HUB_USERNAME}"

echo "=========================================="
echo "Building and Pushing Docker Images"
echo "Docker Hub Username: $REGISTRY"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to build and push image
build_and_push() {
    local service_name=$1
    local dockerfile=$2
    local image_name="${REGISTRY}/${service_name}:latest"
    
    echo -e "\n${BLUE}Building ${service_name}...${NC}"
    
    # Build the binary first (for Go services)
    case $service_name in
        api-gateway)
            echo "Compiling api-gateway..."
            CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/api-gateway ./services/api-gateway
            ;;
        trip-service)
            echo "Compiling trip-service..."
            CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/trip-service ./services/trip-service/cmd/main.go
            ;;
        driver-service)
            echo "Compiling driver-service..."
            CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/driver-service ./services/driver-service
            ;;
        payment-service)
            echo "Compiling payment-service..."
            CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/payment-service ./services/payment-service/cmd/main.go
            ;;
    esac
    
    echo "Building Docker image: $image_name"
    docker build -f "$dockerfile" -t "$image_name" .
    
    echo -e "${GREEN}✓ Built $image_name${NC}"
    
    echo "Pushing to Docker Hub..."
    docker push "$image_name"
    
    echo -e "${GREEN}✓ Pushed $image_name${NC}"
}

# Build and push Go services
echo -e "\n${BLUE}Building Go Services${NC}"
build_and_push "api-gateway" "infra/development/docker/api-gateway.Dockerfile"
build_and_push "trip-service" "infra/development/docker/trip-service.Dockerfile"
build_and_push "driver-service" "infra/development/docker/driver-service.Dockerfile"
build_and_push "payment-service" "infra/development/docker/payment-service.Dockerfile"

# Build and push web frontend
echo -e "\n${BLUE}Building Web Frontend${NC}"
WEB_IMAGE="${REGISTRY}/web:latest"
echo "Building Docker image: $WEB_IMAGE"
docker build -f infra/development/docker/web.Dockerfile -t "$WEB_IMAGE" .
echo -e "${GREEN}✓ Built $WEB_IMAGE${NC}"

echo "Pushing to Docker Hub..."
docker push "$WEB_IMAGE"
echo -e "${GREEN}✓ Pushed $WEB_IMAGE${NC}"

echo -e "\n${GREEN}=========================================="
echo "All images built and pushed successfully!"
echo "=========================================${NC}"
echo ""
echo "Your images are available at:"
echo "  - docker.io/$REGISTRY/api-gateway:latest"
echo "  - docker.io/$REGISTRY/trip-service:latest"
echo "  - docker.io/$REGISTRY/driver-service:latest"
echo "  - docker.io/$REGISTRY/payment-service:latest"
echo "  - docker.io/$REGISTRY/web:latest"
