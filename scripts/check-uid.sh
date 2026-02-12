#!/bin/bash
set -e

DESIRED_UID=999
BASE_IMAGE="ubuntu:26.04"

echo "Checking for UID $DESIRED_UID conflict in $BASE_IMAGE..."

# Create a temporary container to check UIDs
TEMP_CONTAINER=$(podman run --rm -d "$BASE_IMAGE" sleep 1000)
trap "podman stop $TEMP_CONTAINER 2>/dev/null || true" EXIT

# Check if the UID already exists
if podman exec "$TEMP_CONTAINER" grep -q "^[^:]*:[^:]*:$DESIRED_UID:" /etc/passwd; then
    echo "ERROR: UID $DESIRED_UID is already in use in $BASE_IMAGE"
    podman exec "$TEMP_CONTAINER" grep "^[^:]*:[^:]*:$DESIRED_UID:" /etc/passwd
    exit 1
else
    echo "✓ UID $DESIRED_UID is available"
    exit 0
fi
