#!/bin/bash

export KUBECONFIG=~/.kube/config

echo "==> Bedrock Server Status"
echo ""
echo "Namespace:"
kubectl get namespace minecraft 2>/dev/null || echo "  Namespace 'minecraft' not found"

echo ""
echo "Pods:"
kubectl get pods -n minecraft -o wide 2>/dev/null || echo "  No pods found"

echo ""
echo "Deployments:"
kubectl get deployments -n minecraft 2>/dev/null || echo "  No deployments found"

echo ""
echo "Services:"
kubectl get services -n minecraft 2>/dev/null || echo "  No services found"

echo ""
echo "PersistentVolumeClaims:"
kubectl get pvc -n minecraft 2>/dev/null || echo "  No PVCs found"

echo ""
echo "ConfigMaps:"
kubectl get configmaps -n minecraft 2>/dev/null || echo "  No configmaps found"

echo ""
echo "Recent Events:"
kubectl get events -n minecraft --sort-by='.lastTimestamp' 2>/dev/null | tail -10 || echo "  No events found"

echo ""
echo "World Data Usage:"
POD_NAME=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
    WORLD_SIZE=$(kubectl exec -n minecraft $POD_NAME -- du -sh /bedrock/worlds/ 2>/dev/null | cut -f1)
    PVC_SIZE=$(kubectl get pvc bedrock-worlds -n minecraft -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
    echo "  Current: $WORLD_SIZE"
    echo "  Allocated: $PVC_SIZE"
else
    echo "  Server not running"
fi
