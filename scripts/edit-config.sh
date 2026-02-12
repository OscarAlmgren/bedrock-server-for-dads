#!/bin/bash

EDITOR=${EDITOR:-vi}
CONFIG_FILE=~/bedrock-container/k8s/02-configmap.yaml

echo "==> Opening ConfigMap for editing..."
echo ""
echo "Instructions:"
echo "1. Find the 'data:' section"
echo "2. Edit the server.properties values (under 'server.properties: |')"
echo "3. Save and exit"
echo ""
echo "Common settings to change:"
echo "  - max-players=5           (player limit)"
echo "  - view-distance=10        (render distance)"
echo "  - difficulty=easy         (easy/normal/hard)"
echo "  - gamemode=adventure      (survival/creative/adventure)"
echo "  - server-name=...         (server name)"
echo ""
read -p "Press Enter to open editor..."

$EDITOR "$CONFIG_FILE"

echo ""
read -p "Apply changes now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ~/bedrock-container/scripts/update-config.sh
else
    echo "Changes saved but not applied. Run './scripts/update-config.sh' when ready."
fi
