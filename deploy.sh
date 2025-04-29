#!/bin/bash

# Exit if any step fails
set -e

echo "🚀 Building Docker image..."
docker build -t comfyui-server-docker .

echo "🚀 Running local test container..."
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -p 8188:8188 \
  -v $(pwd)/models:/workspace/models \
  -e CADDY_USERNAME=admin \
  -e CADDY_PASSWORD=changeme123 \
  --name comfyui-server-test \
  comfyui-server-docker

echo "✅ Test container started. Please visit http://localhost and check if ComfyUI and Caddy are working."

# Ask user if everything looks fine
read -p "❓ Was everything OK? (yes/no): " confirm

if [ "$confirm" == "yes" ]; then
    echo "🔐 Logging into DockerHub..."
    docker login

    echo "🏷️  Tagging Docker image..."
    docker tag comfyui-server-docker 10xwithankit/comfyui-server-docker:latest

    echo "📤 Pushing Docker image to DockerHub..."
    docker push 10xwithankit/comfyui-server-docker:latest

    echo "🎉 Done! Your image is pushed to DockerHub."
else
    echo "❌ Stopping. No push to DockerHub done."
fi

echo "🧹 Cleaning up local test container..."
docker stop comfyui-server-test
docker rm comfyui-server-test