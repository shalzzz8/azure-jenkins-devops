#!/usr/bin/env bash
# ==============================================================================
# Automated Azure VM Deployment Script
# Invoked by Jenkins CD Pipeline via SSH
# ==============================================================================
set -euo pipefail

APP_DIR="/home/azureuser/app"
CONTAINER_NAME="devops-cicd-app"
IMAGE_NAME="devops-cicd-app:latest"
PORT_MAPPING="80:3000"

echo "=========================================="
echo "⚡ Starting Azure VM Deployment"
echo "📅 Time: $(date -u)"
echo "=========================================="

# 1. Create or clean the app directory
mkdir -p "${APP_DIR}"
echo "📦 Extracting application package to ${APP_DIR}..."
tar -xzf /home/azureuser/app-package.tar.gz -C "${APP_DIR}"
rm -f /home/azureuser/app-package.tar.gz

# 2. Build the Docker image
echo "🔨 Building Docker image: ${IMAGE_NAME}..."
cd "${APP_DIR}"
docker build -t "${IMAGE_NAME}" .

# 3. Stop and remove previous container if running
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "🛑 Stopping existing container '${CONTAINER_NAME}'..."
    docker stop "${CONTAINER_NAME}"
fi

if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "🗑️ Removing old container '${CONTAINER_NAME}'..."
    docker rm "${CONTAINER_NAME}"
fi

# 4. Run new container
echo "🚀 Starting new container '${CONTAINER_NAME}' on port 80..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p ${PORT_MAPPING} \
    "${IMAGE_NAME}"

# 5. Clean up dangling images
docker image prune -f || true

# 6. Verify container is running
echo "🔍 Validating container status..."
sleep 2
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "✅ Container is running successfully!"
    docker ps -f name="^/${CONTAINER_NAME}$"
else
    echo "❌ Container failed to start! Recent logs:"
    docker logs "${CONTAINER_NAME}"
    exit 1
fi

echo "=========================================="
echo "✨ Deployment Completed Successfully!"
echo "=========================================="
