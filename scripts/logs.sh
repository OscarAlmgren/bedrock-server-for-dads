#!/bin/bash

export KUBECONFIG=~/.kube/config

FOLLOW=false
LINES=100

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -n|--lines)
            LINES="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-f|--follow] [-n|--lines NUM]"
            exit 1
            ;;
    esac
done

if [ "$FOLLOW" = true ]; then
    echo "==> Following Bedrock server logs (Ctrl+C to exit)..."
    kubectl logs -n minecraft -l app=bedrock-server -f
else
    echo "==> Bedrock server logs (last $LINES lines):"
    kubectl logs -n minecraft -l app=bedrock-server --tail="$LINES"
fi
