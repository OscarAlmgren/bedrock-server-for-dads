# Bedrock Minecraft Server - Kubernetes Deployment

Containerized Minecraft Bedrock Server running on K3s with optimized settings for the server in a wardrobe context.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Management Scripts](#management-scripts)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Backup & Restore](#backup--restore)
- [Lifecycle Management](#lifecycle-management)

---

## Overview

This deployment runs Minecraft Bedrock Server **1.26.0.2** in a Kubernetes pod with:
- ✅ Persistent world data storage
- ✅ Optimized configuration for low-resource hardware
- ✅ Easy management via kubectl and custom scripts
- ✅ Automatic pod restarts on failures
- ✅ Health checks and readiness probes

### Server Specifications
- **Version**: 1.26.0.2
- **Max Players**: 5
- **View Distance**: 10 chunks
- **Tick Distance**: 3 chunks
- **Compression**: Snappy (faster than zlib)
- **Ports**: 19132 (UDP IPv4), 19133 (UDP IPv6)

---

## Architecture

```
┌────────────────────────────────────────┐
│   The Dads Minecraft Srv (your LAN ip) │
│                                        │
│  ┌────────────────────────────────┐    │
│  │         K3s Cluster            │    │
│  │                                │    │
│  │  ┌──────────────────────────┐  │    │
│  │  │  minecraft namespace     │  │    │
│  │  │                          │  │    │
│  │  │  ┌────────────────────┐  │  │    │
│  │  │  │  bedrock-server    │  │  │    │
│  │  │  │  Pod               │  │  │    │
│  │  │  │                    │  │  │    │
│  │  │  │  ┌──────────────┐  │  │  │    │
│  │  │  │  │  Container   │  │  │  │    │
│  │  │  │  │  :19132/udp  │  │  │  │    │
│  │  │  │  │  :19133/udp  │  │  │  │    │
│  │  │  │  └──────────────┘  │  │  │    │
│  │  │  │         ↓          │  │  │    │
│  │  │  │  ┌──────────────┐  │  │  │    │
│  │  │  │  │ PVC (1 GB)   │  │  │  │    │
│  │  │  │  │ World Data   │  │  │  │    │
│  │  │  │  └──────────────┘  │  │  │    │
│  │  │  └────────────────────┘  │  │    │
│  │  │                          │  │    │
│  │  │  ┌────────────────────┐  │  │    │
│  │  │  │  ConfigMap         │  │  │    │
│  │  │  │  server.properties │  │  │    │
│  │  │  └────────────────────┘  │  │    │
│  │  └──────────────────────────┘  │    │
│  └────────────────────────────────┘    │
└────────────────────────────────────────┘
```

---

## Quick Start

### Prerequisites
- K3s cluster running on your Linux server
- kubectl configured with access to the cluster
- KUBECONFIG set to `~/.kube/config`

### Deploy the Server
```bash
cd ~/bedrock-container
./scripts/deploy.sh
```

### Check Status
```bash
./scripts/status.sh
```

### View Logs
```bash
./scripts/logs.sh          # Last 100 lines
./scripts/logs.sh -f       # Follow logs in real-time
./scripts/logs.sh -n 200   # Last 200 lines
```

---

## Management Scripts

All scripts are located in `~/bedrock-container/scripts/`.

### `build.sh`
Builds the Docker image and imports it into K3s.

```bash
./scripts/build.sh
```

**When to use:**
- After updating the Bedrock server binary
- After modifying the Dockerfile
- When creating a new version

### `deploy.sh`
Deploys/updates the Bedrock server to K3s.

```bash
./scripts/deploy.sh
```

**What it does:**
1. Applies all Kubernetes manifests
2. Waits for deployment to be ready
3. Shows deployment status and logs

### `stop.sh`
Gracefully stops the Bedrock server.

```bash
./scripts/stop.sh
```

**What it does:**
- Scales the deployment to 0 replicas
- Waits for pod to terminate
- World data remains safe on persistent volume

### `restart.sh`
Restarts the Bedrock server.

```bash
./scripts/restart.sh
```

**When to use:**
- After changing configuration
- When server becomes unresponsive
- After applying updates

### `logs.sh`
View server logs.

```bash
./scripts/logs.sh               # Last 100 lines
./scripts/logs.sh -f            # Follow logs
./scripts/logs.sh -n 500        # Last 500 lines
./scripts/logs.sh -f -n 50      # Follow with 50 lines history
```

### `status.sh`
Shows comprehensive server status.

```bash
./scripts/status.sh
```

**Shows:**
- Namespace status
- Pod status and IP address
- Deployment status
- Service endpoints
- PersistentVolumeClaim status
- Recent events

### `backup.sh`
Creates a backup of world data.

```bash
./scripts/backup.sh
```

**Output:** `~/bedrock-backups/bedrock-worlds-YYYYMMDD-HHMMSS.tar.gz`

**Best practices:**
- Run before major updates
- Run before configuration changes
- Schedule regular backups (see cron example below)

### `restore.sh`
Restores world data from a backup.

```bash
./scripts/restore.sh ~/bedrock-backups/bedrock-worlds-20260110-103000.tar.gz
```

**What it does:**
1. Uploads backup to running pod
2. Extracts world data
3. Restarts server to apply changes

### `update-config.sh`
Updates server.properties without rebuilding the image.

```bash
# 1. Edit the ConfigMap
vi ~/bedrock-container/k8s/02-configmap.yaml

# 2. Apply changes
./scripts/update-config.sh
```

**What it does:**
1. Updates the ConfigMap in Kubernetes
2. Restarts the server pod to pick up new config

---

## Configuration

### Server Properties

Edit `~/bedrock-container/k8s/02-configmap.yaml` to change server settings.

**Key settings:**
```yaml
max-players=5                              # Player limit
view-distance=10                           # Chunk view distance
tick-distance=3                            # Simulation distance
max-threads=2                              # CPU threads (match cores)
compression-algorithm=snappy               # Compression method
compression-threshold=256                  # Min bytes to compress
server-authoritative-movement-strict=true  # Anti-cheat
```

**After editing:**
```bash
./scripts/update-config.sh
```

### Resource Limits

Edit `~/bedrock-container/k8s/03-deployment.yaml`:

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "2000m"
```

**After editing:**
```bash
./scripts/deploy.sh
```

### Persistent Storage

Default: 1 GB for world data.

To change:
```bash
# Edit PVC size
vi ~/bedrock-container/k8s/01-pvc.yaml

# Change this line:
storage: 1Gi  # Increase as needed
```

**Note:** K3s uses `local-path` storage, which uses host filesystem space.

---

## Troubleshooting

### Server Won't Start

```bash
# Check pod status
./scripts/status.sh

# View logs for errors
./scripts/logs.sh -n 200

# Check pod events
export KUBECONFIG=~/.kube/config
kubectl describe pod -n minecraft -l app=bedrock-server
```

### Cannot Connect from Minecraft Client

1. **Verify server is running:**
```bash
./scripts/status.sh
# Look for: pod/bedrock-server-xxx READY 1/1 Running
```

2. **Check ports are accessible:**
```bash
sudo netstat -ulnp | grep 19132
# Should show bedrock_server listening on both ports
```

3. **Verify server IP:**
- Server IP: **192.168.0.170**
- Port: **19132** (default)

4. **Check firewall:**
```bash
sudo ufw status
# Ensure ports 19132 and 19133 UDP are allowed
```

### World Data Missing

```bash
# Check if PVC is mounted
export KUBECONFIG=~/.kube/config
kubectl describe pod -n minecraft -l app=bedrock-server | grep -A 5 "Mounts:"

# Check world directory inside pod
POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n minecraft $POD -- ls -la /bedrock/worlds/
```

### High CPU Usage

1. **Reduce view distance:**
```bash
vi ~/bedrock-container/k8s/02-configmap.yaml
# Change: view-distance=10 to view-distance=8
./scripts/update-config.sh
```

2. **Reduce player limit:**
```bash
vi ~/bedrock-container/k8s/02-configmap.yaml
# Change: max-players=5 to max-players=3
./scripts/update-config.sh
```

### Pod Crashing (CrashLoopBackOff)

```bash
# View crash logs
./scripts/logs.sh -n 100

# Check pod description
export KUBECONFIG=~/.kube/config
kubectl describe pod -n minecraft -l app=bedrock-server

# Common causes:
# - Insufficient memory (increase limits)
# - Corrupted world data (restore from backup)
# - Invalid configuration (check ConfigMap)
```

---

## Backup & Restore

### Manual Backup
```bash
./scripts/backup.sh
```

Backups are stored in: `~/bedrock-backups/`

### Automated Backups with Cron

```bash
# Edit crontab
crontab -e

# Add this line for daily backups at 3 AM
0 3 * * * /home/oscaralmgren/bedrock-container/scripts/backup.sh

# Or every 6 hours:
0 */6 * * * /home/oscaralmgren/bedrock-container/scripts/backup.sh
```

### Restore from Backup

```bash
# List available backups
ls -lht ~/bedrock-backups/

# Restore specific backup
./scripts/restore.sh ~/bedrock-backups/bedrock-worlds-20260110-103000.tar.gz
```

**Warning:** Restore will overwrite current world data!

### Backup Retention

Keep backups clean to save disk space:

```bash
# Keep only last 7 days of backups
find ~/bedrock-backups/ -name "bedrock-worlds-*.tar.gz" -mtime +7 -delete

# Add to crontab for automatic cleanup:
0 4 * * * find ~/bedrock-backups/ -name "bedrock-worlds-*.tar.gz" -mtime +7 -delete
```

---

## Lifecycle Management

### Starting the Server
```bash
# If stopped (replicas=0)
export KUBECONFIG=~/.kube/config
kubectl scale deployment bedrock-server -n minecraft --replicas=1

# Or use restart script
./scripts/restart.sh
```

### Stopping the Server
```bash
./scripts/stop.sh
```

### Updating Bedrock Server Version

1. **Download new version:**
```bash
cd ~
wget https://minecraft.azureedge.net/bin-linux/bedrock-server-X.X.X.X.zip
unzip bedrock-server-X.X.X.X.zip -d "Bedrock Server X.X.X.X"
```

2. **Update Dockerfile image tag:**
```bash
vi ~/bedrock-container/Dockerfile
# Update version in comments if needed
```

3. **Update deployment manifest:**
```bash
vi ~/bedrock-container/k8s/03-deployment.yaml
# Change image tag to new version
```

4. **Rebuild and deploy:**
```bash
cd ~/bedrock-container
./scripts/build.sh
./scripts/deploy.sh
```

### Undeploying the Server

```bash
export KUBECONFIG=~/.kube/config

# Delete all resources (keeps PVC/data)
kubectl delete deployment bedrock-server -n minecraft
kubectl delete service bedrock-server -n minecraft
kubectl delete configmap bedrock-config -n minecraft

# Delete PVC (WARNING: Deletes world data!)
kubectl delete pvc bedrock-worlds -n minecraft

# Delete namespace
kubectl delete namespace minecraft
```

**To keep backups before undeploying:**
```bash
./scripts/backup.sh
```

---

## Monitoring

### View Resource Usage
```bash
export KUBECONFIG=~/.kube/config
kubectl top pod -n minecraft
```

### View Events
```bash
export KUBECONFIG=~/.kube/config
kubectl get events -n minecraft --sort-by='.lastTimestamp'
```

### Check Network Ports
```bash
# On host
sudo netstat -ulnp | grep bedrock_server

# Expected output:
# udp   0   0   0.0.0.0:19132   0.0.0.0:*   xxx/bedrock_server
# udp   0   0   :::19133        :::*        xxx/bedrock_server
```

---

## Performance Tuning

### Current Optimizations Applied
- ✅ **max-threads=2** - Matches CPU cores
- ✅ **view-distance=10** - Reduced from 32 (90% fewer chunks)
- ✅ **tick-distance=3** - Reduced from 4
- ✅ **compression-algorithm=snappy** - Faster than zlib
- ✅ **compression-threshold=256** - Skip tiny packets
- ✅ **max-players=5** - Realistic for hardware

### Further Optimization (If Needed)

**If experiencing lag:**

1. Reduce view distance to 8:
```yaml
view-distance=8
```

2. Reduce max players to 3:
```yaml
max-players=3
```

3. Increase resource limits:
```yaml
limits:
  memory: "1.5Gi"
  cpu: "2000m"
```

---

## Directory Structure

```
~/bedrock-container/
├── Dockerfile                 # Container image definition
├── .dockerignore              # Files to exclude from image
├── README.md                  # This file
├── k8s/                       # Kubernetes manifests
│   ├── 00-namespace.yaml      # Minecraft namespace
│   ├── 01-pvc.yaml            # Persistent storage
│   ├── 02-configmap.yaml      # Server configuration
│   ├── 03-deployment.yaml     # Pod deployment
│   └── 04-service.yaml        # Network service
├── scripts/                   # Management scripts
│   ├── build.sh               # Build & import image
│   ├── deploy.sh              # Deploy to K3s
│   ├── stop.sh                # Stop server
│   ├── restart.sh             # Restart server
│   ├── logs.sh                # View logs
│   ├── status.sh              # Check status
│   ├── backup.sh              # Backup worlds
│   ├── restore.sh             # Restore worlds
│   └── update-config.sh       # Update configuration
└── docs/                      # Additional documentation
    └── OPERATIONS.md          # Operational procedures

~/bedrock-backups/             # Backup storage
└── bedrock-worlds-*.tar.gz    # World backups

~/.kube/config                 # Kubectl configuration
```

---

## Support & Maintenance

### Logs Location
- **Container logs:** `kubectl logs -n minecraft -l app=bedrock-server`
- **K3s logs:** `journalctl -u k3s -f`
- **System logs:** `/var/log/syslog`

### Useful Commands

```bash
# Get into pod shell
export KUBECONFIG=~/.kube/config
POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n minecraft $POD -- /bin/bash

# Copy file from pod
kubectl cp minecraft/$POD:/bedrock/server.properties ./server.properties

# Copy file to pod
kubectl cp ./allowlist.json minecraft/$POD:/bedrock/allowlist.json

# Watch pod status in real-time
kubectl get pods -n minecraft --watch

# Force delete pod (recreates immediately)
kubectl delete pod -n minecraft $POD --force --grace-period=0
```

---

## Migration from Binary Installation

The old binary installation has been preserved in:
- **Directory:** `~/Bedrock Server 1.21.132.backup-TIMESTAMP`
- **Configuration:** `server.properties.backup-TIMESTAMP`

To completely remove old installation:
```bash
# Verify containerized version is working first!
./scripts/status.sh
./scripts/logs.sh

# Remove old backup directories
rm -rf ~/"Bedrock Server 1.21.132"*
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.21.132.3 | 2026-01-10 | Initial containerized deployment |
| 1.26.0.2 | 2026-02-12 | Updated for new Minecraft server version 1.26.0.2 |
---

## License

Minecraft Bedrock Server © Mojang Studios / Microsoft

Container configuration and scripts: MIT License

---

**For questions or issues, check the troubleshooting section or review pod logs with `./scripts/logs.sh`**
