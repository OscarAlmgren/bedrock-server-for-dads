#!/bin/bash
set -e

export KUBECONFIG=~/.kube/config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$PROJECT_DIR/k8s"

echo "==> Updating ConfigMap..."
kubectl apply -f "$K8S_DIR/02-configmap.yaml"

echo ""
echo "==> Restarting server to apply new configuration..."
POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD" ]; then
    echo "Warning: No running pod found"
else
    kubectl delete pod -n minecraft "$POD"
    echo "==> Waiting for new pod to be ready..."
    kubectl wait --for=condition=ready pod -l app=bedrock-server -n minecraft --timeout=120s
fi

echo ""
echo "==> Configuration updated!"
