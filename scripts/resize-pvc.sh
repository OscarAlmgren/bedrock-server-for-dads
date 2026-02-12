#!/bin/bash
set -e

export KUBECONFIG=~/.kube/config

if [ $# -ne 1 ]; then
    echo "Usage: $0 <new-size>"
    echo ""
    echo "Examples:"
    echo "  $0 500Mi   # 500 megabytes"
    echo "  $0 1Gi    # 1 gigabyte"
    echo "  $0 2Gi    # 2 gigabytes"
    echo ""
    echo "Current PVC size:"
    kubectl get pvc bedrock-worlds -n minecraft -o jsonpath='{.spec.resources.requests.storage}'
    echo ""
    exit 1
fi

NEW_SIZE="$1"

echo "==========================================="
echo "RESIZE PVC - WARNING"
echo "==========================================="
echo ""
echo "This will:"
echo "  1. Create backup of current world"
echo "  2. Stop the server"
echo "  3. Delete old PVC (10Gi)"
echo "  4. Create new PVC ($NEW_SIZE)"
echo "  5. Restore world data"
echo "  6. Restart server"
echo ""
echo "Current world size:"
POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n minecraft $POD -- du -sh /bedrock/worlds/ 2>/dev/null || echo "  Unable to check (server may be stopped)"
echo ""
read -p "Continue with resize to $NEW_SIZE? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Creating backup..."
~/bedrock-container/scripts/backup.sh

echo ""
echo "Step 2: Stopping server..."
~/bedrock-container/scripts/stop.sh

echo ""
echo "Step 3: Deleting old PVC..."
kubectl delete pvc bedrock-worlds -n minecraft
echo "Waiting for PVC deletion..."
sleep 5

echo ""
echo "Step 4: Creating new PVC with size $NEW_SIZE..."
cat > /tmp/new-pvc.yaml << EOFPVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: bedrock-worlds
  namespace: minecraft
  labels:
    app: bedrock-server
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: $NEW_SIZE
  storageClassName: local-path
EOFPVC

kubectl apply -f /tmp/new-pvc.yaml
rm /tmp/new-pvc.yaml

echo ""
echo "Step 5: Starting server with new PVC..."
kubectl scale deployment bedrock-server -n minecraft --replicas=1
echo "Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod -l app=bedrock-server -n minecraft --timeout=120s

echo ""
echo "Step 6: Restoring world data..."
LATEST_BACKUP=$(ls -t ~/bedrock-backups/bedrock-worlds-*.tar.gz | head -1)
echo "Using backup: $LATEST_BACKUP"

POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}')
cat "$LATEST_BACKUP" | kubectl exec -n minecraft -i "$POD" -- tar xzf - -C /bedrock

echo ""
echo "Step 7: Restarting server to apply changes..."
kubectl delete pod -n minecraft "$POD"
kubectl wait --for=condition=ready pod -l app=bedrock-server -n minecraft --timeout=120s

echo ""
echo "==========================================="
echo "RESIZE COMPLETE"
echo "==========================================="
echo ""
echo "New PVC size: $NEW_SIZE"
kubectl get pvc bedrock-worlds -n minecraft
echo ""
echo "World data size:"
POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n minecraft $POD -- du -sh /bedrock/worlds/
echo ""
echo "Server status:"
kubectl get pods -n minecraft
