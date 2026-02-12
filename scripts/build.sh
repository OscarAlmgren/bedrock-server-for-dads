#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "==> Stopping current binary server..."
pkill -f bedrock_server || true
sleep 2

echo "==> Copying server files for build..."
cp -r "$HOME/Bedrock Server 1.26.0.2/"* "$PROJECT_DIR/"
rm -f *.log nohup.out *.backup-*

echo "==> Checking UID availability..."
./scripts/check-uid.sh
echo "==> Building Docker image..."
podman build --no-cache -t oscaralmgren/bedrock-server:1.26.0.2 -t oscaralmgren/bedrock-server:latest .

echo "==> Pushing to docker.io..."
podman push oscaralmgren/bedrock-server:1.26.0.2
podman push oscaralmgren/bedrock-server:latest

echo "==> Build and push complete!"
podman images | grep bedrock-server
