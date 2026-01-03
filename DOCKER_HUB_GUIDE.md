# Docker Hub Deployment Guide

## Prerequisites

1. **Docker installed** - [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
2. **Docker Hub account** - [Create free account](https://hub.docker.com)
3. **Logged in to Docker Hub**:
   ```bash
   docker login
   ```
   Enter your Docker Hub username and password when prompted.

## Step 1: Prepare Your Environment

```bash
# Clone the repository (if you haven't already)
cd /path/to/ride-sharing

# Make sure all code is committed
git add .
git commit -m "Ready for Docker Hub deployment"
```

## Step 2: Build and Push Images

### Option A: Automated (Recommended)

```bash
# Make the script executable
chmod +x build-and-push.sh

# Run the script with your Docker Hub username
./build-and-push.sh your-docker-hub-username
```

Example:
```bash
./build-and-push.sh azizul
```

This will build and push all images:
- `docker.io/azizul/api-gateway:latest`
- `docker.io/azizul/trip-service:latest`
- `docker.io/azizul/driver-service:latest`
- `docker.io/azizul/payment-service:latest`
- `docker.io/azizul/web:latest`

### Option B: Manual Build & Push

#### API Gateway
```bash
# Build
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/api-gateway ./services/api-gateway

# Build Docker image
docker build -f infra/development/docker/api-gateway.Dockerfile -t your-username/api-gateway:latest .

# Push
docker push your-username/api-gateway:latest
```

#### Trip Service
```bash
# Build
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/trip-service ./services/trip-service/cmd/main.go

# Build Docker image
docker build -f infra/development/docker/trip-service.Dockerfile -t your-username/trip-service:latest .

# Push
docker push your-username/trip-service:latest
```

#### Driver Service
```bash
# Build
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/driver-service ./services/driver-service

# Build Docker image
docker build -f infra/development/docker/driver-service.Dockerfile -t your-username/driver-service:latest .

# Push
docker push your-username/driver-service:latest
```

#### Payment Service
```bash
# Build
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/payment-service ./services/payment-service/cmd/main.go

# Build Docker image
docker build -f infra/development/docker/payment-service.Dockerfile -t your-username/payment-service:latest .

# Push
docker push your-username/payment-service:latest
```

#### Web Frontend
```bash
# Build Docker image
docker build -f infra/development/docker/web.Dockerfile -t your-username/web:latest .

# Push
docker push your-username/web:latest
```

## Step 3: Verify on Docker Hub

1. Go to [Docker Hub](https://hub.docker.com)
2. Log in with your credentials
3. You should see all your pushed repositories in your dashboard

## Step 4: Update Kubernetes Deployments (Optional)

To use your own Docker Hub images in Kubernetes, update the image references in your deployment files:

### For Production:
```yaml
# infra/production/k8s/api-gateway-deployment.yaml
image: your-username/api-gateway:latest
```

### For Development with Tilt:
Update your `Tiltfile` to use your images (currently it uses local `ride-sharing/` prefix).

## Step 5: Deploy from Docker Hub

```bash
# Pull and run an image locally
docker run -p 8081:8081 your-username/api-gateway:latest

# Or deploy to Kubernetes with your images
kubectl set image deployment/api-gateway \
  api-gateway=your-username/api-gateway:latest
```

## Troubleshooting

### "unauthorized: authentication required"
```bash
# Re-login to Docker Hub
docker logout
docker login
```

### "denied: requested access to the resource is denied"
- Check that your Docker Hub username is correct
- Ensure the repository is public or you have access

### "permission denied while trying to connect to the Docker daemon"
```bash
# Add your user to the docker group (Linux)
sudo usermod -aG docker $USER
newgrp docker
```

### Build Errors
```bash
# Clear Docker build cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -f infra/development/docker/api-gateway.Dockerfile -t your-username/api-gateway:latest .
```

## Tags and Versioning

To push specific versions:

```bash
# Build with version tag
docker build -f infra/development/docker/api-gateway.Dockerfile -t your-username/api-gateway:v1.0.0 .

# Push both latest and version
docker push your-username/api-gateway:v1.0.0
docker push your-username/api-gateway:latest
```

## Next Steps

- Set up automated builds with GitHub Actions
- Configure container registries for your deployment
- Implement proper secret management for production
- Use Docker Compose for local multi-container testing
