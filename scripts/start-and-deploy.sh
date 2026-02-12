#!/bin/bash
set -e

export KUBECONFIG=~/.kube/config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$PROJECT_DIR/k8s"

echo "==> Applying Kubernetes manifests..."
kubectl apply -f "$K8S_DIR/00-namespace.yaml"
kubectl apply -f "$K8S_DIR/01-pvc.yaml"
kubectl apply -f "$K8S_DIR/02-configmap.yaml"
kubectl apply -f "$K8S_DIR/03-deployment.yaml"
kubectl apply -f "$K8S_DIR/04-service.yaml"

echo ""
echo "==> Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/bedrock-server -n minecraft || true

echo ""
echo "==> Deployment status:"
kubectl get all -n minecraft

echo ""
echo "==> Pod logs (last 20 lines):"
kubectl logs -n minecraft -l app=bedrock-server --tail=20 || echo "No logs yet"

echo ""
echo "==> Deployment complete!"
