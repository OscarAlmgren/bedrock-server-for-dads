#!/bin/bash
set -e

export KUBECONFIG=~/.kube/config

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup-file>"
    echo ""
    echo "Available backups:"
    ls -lht "$HOME/bedrock-backups" 2>/dev/null || echo "  No backups found"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "==> Restoring from backup: $BACKUP_FILE"

POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD" ]; then
    echo "Error: No running Bedrock server pod found"
    echo "Please start the server first with: ~/bedrock-container/scripts/restart.sh"
    exit 1
fi

echo "==> Restoring to pod: $POD"
cat "$BACKUP_FILE" | kubectl exec -n minecraft -i "$POD" -- tar xzf - -C /bedrock

echo ""
echo "==> Restore complete!"
echo "==> Restarting server to apply changes..."
kubectl delete pod -n minecraft "$POD"

echo ""
echo "==> Waiting for new pod to be ready..."
kubectl wait --for=condition=ready pod -l app=bedrock-server -n minecraft --timeout=120s

echo ""
echo "==> Server restored and restarted!"
