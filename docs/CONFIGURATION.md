# Bedrock Server Configuration Guide

## Quick Start

### Easy Method (Recommended)
```bash
cd ~/bedrock-container
./scripts/edit-config.sh
```

This opens the ConfigMap, shows instructions, and applies changes for you.

---

## Understanding the Configuration System

Your server configuration is stored in a **Kubernetes ConfigMap**, not a regular file.

### File Location
```
~/bedrock-container/k8s/02-configmap.yaml
```

### Structure
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: bedrock-config
  namespace: minecraft
data:
  server.properties: |
    # All your server settings go here
    server-name=Hugos Minecraft
    max-players=5
    view-distance=10
    difficulty=easy
    gamemode=adventure
    # ... etc
```

---

## Common Configuration Changes

### Change Player Limit

**Edit:** `~/bedrock-container/k8s/02-configmap.yaml`

Find and change:
```yaml
max-players=5
```

To:
```yaml
max-players=10
```

**Apply:**
```bash
./scripts/update-config.sh
```

---

### Change Difficulty

**Options:** peaceful, easy, normal, hard

```yaml
difficulty=normal
```

---

### Change Game Mode

**Options:** survival, creative, adventure

```yaml
gamemode=survival
```

---

### Change View Distance

**Range:** 5-32 chunks (lower = better performance)

```yaml
view-distance=12
```

---

### Change Server Name

```yaml
server-name=My Awesome Server
```

---

### Enable Cheats

```yaml
allow-cheats=true
```

---

## Performance Settings

### Optimized for Low Resources (Current)
```yaml
max-players=5
view-distance=10
tick-distance=3
max-threads=2
compression-algorithm=snappy
compression-threshold=256
```

### Moderate Performance
```yaml
max-players=8
view-distance=12
tick-distance=4
max-threads=2
```

### High Performance (Good Hardware)
```yaml
max-players=15
view-distance=16
tick-distance=6
max-threads=4
```

---

## Step-by-Step Configuration Workflow

### 1. Edit ConfigMap
```bash
vi ~/bedrock-container/k8s/02-configmap.yaml
```

### 2. Find the data section
Look for:
```yaml
data:
  server.properties: |
    # Settings start here
```

### 3. Modify settings
Change any values under `server.properties: |`

### 4. Save and exit
- In vi: Press `ESC` then type `:wq` and press Enter

### 5. Apply changes
```bash
./scripts/update-config.sh
```

### 6. Verify changes applied
```bash
./scripts/logs.sh -n 20
```

Look for lines like:
```
[INFO] Game mode: 2 Adventure
[INFO] Difficulty: 1 EASY
```

---

## Advanced: All Available Settings

### Server Identity
```yaml
server-name=Hugos Minecraft           # Server name in server list
level-name=Bedrock level              # World name
```

### Gameplay
```yaml
gamemode=adventure                    # survival, creative, adventure
force-gamemode=false                  # Force gamemode on join
difficulty=easy                       # peaceful, easy, normal, hard
allow-cheats=false                    # Enable commands
```

### Players
```yaml
max-players=5                         # Max concurrent players
online-mode=true                      # Xbox Live authentication
allow-list=false                      # Whitelist mode
default-player-permission-level=member # visitor, member, operator
player-idle-timeout=30                # Kick after X minutes idle
```

### Performance
```yaml
view-distance=10                      # Render distance (chunks)
tick-distance=3                       # Simulation distance
max-threads=2                         # CPU threads to use
server-authoritative-movement-strict=true  # Anti-cheat
```

### Network
```yaml
server-port=19132                     # IPv4 port
server-portv6=19133                   # IPv6 port
enable-lan-visibility=true            # LAN discovery
compression-algorithm=snappy          # snappy or zlib
compression-threshold=256             # Min bytes to compress
```

### Content
```yaml
texturepack-required=false            # Force resource pack
content-log-file-enabled=false        # Log content errors
```

---

## Verifying Changes

### Check if pod restarted
```bash
./scripts/status.sh
```

Look for recent pod age (e.g., `30s` instead of `1h`)

### Check logs for new settings
```bash
./scripts/logs.sh -n 30
```

Look for:
```
[INFO] Game mode: X
[INFO] Difficulty: X
[INFO] Level Name: X
```

### Check config inside pod
```bash
export KUBECONFIG=~/.kube/config
POD=$(kubectl get pod -n minecraft -l app=bedrock-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n minecraft $POD -- cat /bedrock/server.properties | grep max-players
```

---

## Troubleshooting

### Changes not applying?

**Check ConfigMap updated:**
```bash
export KUBECONFIG=~/.kube/config
kubectl get configmap bedrock-config -n minecraft -o yaml | grep max-players
```

**Force pod restart:**
```bash
./scripts/restart.sh
```

### Invalid configuration?

**Check pod logs for errors:**
```bash
./scripts/logs.sh -n 50
```

**Restore from backup config:**
```bash
# Copy from backup
cp ~/bedrock-container/k8s/02-configmap.yaml.bak ~/bedrock-container/k8s/02-configmap.yaml

# Apply
./scripts/update-config.sh
```

### Pod in CrashLoopBackOff?

**Restore default config:**
```bash
git checkout ~/bedrock-container/k8s/02-configmap.yaml
./scripts/update-config.sh
```

---

## Configuration Best Practices

1. **Always backup before major changes:**
   ```bash
   cp ~/bedrock-container/k8s/02-configmap.yaml ~/bedrock-container/k8s/02-configmap.yaml.backup
   ```

2. **Test changes in low-traffic periods**

3. **One change at a time** - easier to troubleshoot

4. **Monitor after changes:**
   ```bash
   ./scripts/logs.sh -f
   ```

5. **Keep a record of working configs**

---

## Examples

### Example 1: Increase player limit and difficulty
```yaml
max-players=10
difficulty=normal
```

### Example 2: Switch to survival mode
```yaml
gamemode=survival
difficulty=normal
allow-cheats=false
```

### Example 3: Creative server
```yaml
gamemode=creative
allow-cheats=true
difficulty=peaceful
```

### Example 4: Performance optimization
```yaml
view-distance=8
tick-distance=3
max-threads=2
compression-algorithm=snappy
max-players=4
```

---

## See Also

- [README.md](../README.md) - Main documentation
- [Troubleshooting](../README.md#troubleshooting) - Common issues
- [Performance Tuning](../README.md#performance-tuning) - Optimization guide
