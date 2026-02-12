#!/bin/bash
set -e

export KUBECONFIG=~/.kube/config

BACKUP_DIR="$HOME/bedrock-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/bedrock-worlds-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "==> Creating backup of world data..."
POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD" ]; then
    echo "Error: No running Bedrock server pod found"
    exit 1
fi

echo "==> Backing up from pod: $POD"
kubectl exec -n minecraft "$POD" -- tar czf - -C /bedrock worlds > "$BACKUP_FILE"

echo ""
echo "==> Backup complete!"
echo "Backup file: $BACKUP_FILE"
echo "Size: $(du -h "$BACKUP_FILE" | cut -f1)"

echo ""
echo "==> Recent backups:"
ls -lht "$BACKUP_DIR" | head -6
