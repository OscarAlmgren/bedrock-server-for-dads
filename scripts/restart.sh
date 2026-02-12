#!/bin/bash
set -e

export KUBECONFIG=~/.kube/config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Stopping Bedrock server..."
"$SCRIPT_DIR/stop.sh"

echo ""
echo "==> Starting Bedrock server..."
kubectl scale deployment bedrock-server -n minecraft --replicas=1

echo ""
echo "==> Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/bedrock-server -n minecraft || true

echo ""
echo "==> Server restarted!"
kubectl get all -n minecraft
