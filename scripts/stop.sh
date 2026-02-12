#!/bin/bash
set -e

export KUBECONFIG=~/.kube/config

echo "==> Scaling down Bedrock server..."
kubectl scale deployment bedrock-server -n minecraft --replicas=0

echo ""
echo "==> Waiting for pod to terminate..."
kubectl wait --for=delete pod -l app=bedrock-server -n minecraft --timeout=60s || true

echo ""
echo "==> Bedrock server stopped"
kubectl get all -n minecraft
