#!/bin/bash

echo "=== Bedrock Server External Connection Test ==="
echo ""

# Get internal LAN IP (first non-loopback IPv4 address)
INTERNAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127\.' | head -1)
echo "0. Your Internal IP: $INTERNAL_IP"
echo ""

# Get external IP
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null)
echo "1. Your External IP: $EXTERNAL_IP"
echo ""

# Check server is listening
echo "2. Server listening on UDP ports:"
sudo ss -ulnp | grep bedrock_server | grep -E '19132|19133'
echo ""

# Check firewall
echo "3. Firewall allows UDP 19132/19133:"
sudo ufw status | grep -E '19132|19133'
echo ""

# Test from server itself
echo "4. Testing UDP port from server (should timeout - that's OK):"
timeout 3 nc -vuz $EXTERNAL_IP 19132 2>&1 || echo "   (This is expected to timeout from inside network)"
echo ""

echo "=== NEXT STEPS ==="
echo ""
echo "Router Port Forwarding - CHECK THESE:"
echo "  External IP: $EXTERNAL_IP"
echo "  External Port: 19132"
echo "  Make sure the port forwarding host:* to allow anyone to connect and play with kids+friends! "
echo "  Protocol: UDP (NOT TCP!)"
echo "  Internal IP: $INTERNAL_IP"
echo "  Internal Port: 19132"
echo ""
echo "Test from external device:"
echo "  Server: $EXTERNAL_IP"
echo "  Port: 19132 (usually auto-detected)"
echo ""
echo "Online tools (Bedrock-compatible):"
echo "  https://mcsrvstat.us/bedrock/$EXTERNAL_IP:19132"
