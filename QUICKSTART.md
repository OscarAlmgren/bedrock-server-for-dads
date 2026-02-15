# 🎮 Bedrock Server - Quick Reference

## ⚡ Configuration Changes

### Option 1: Easy Way (Interactive)

```bash
cd ~/bedrock-container
./scripts/edit-config.sh
```

Opens editor → Make changes → Auto-applies

### Option 2: Manual Way

```bash
# 1. Edit
nano ~/bedrock-container/k8s/02-configmap.yaml

# 2. Find this section:
#    data:
#      server.properties: |
#        max-players=5        ← Change this

# 3. Apply
./scripts/update-config.sh
```

**⚠️ IMPORTANT:** Edit the **ConfigMap YAML file, 02-configmap.yaml**, not server.properties directly!

---

## 🛠️ Common Commands

```bash
cd ~/bedrock-container

./scripts/start-and-deploy.sh # Deploy+Start in K3s or K8s
./scripts/status.sh           # Check server status
./scripts/logs.sh -f          # Follow logs live
./scripts/logs.sh -n 50       # Last 50 log lines
./scripts/restart.sh          # Restart server
./scripts/stop.sh             # Stop server
./scripts/backup.sh           # Backup world
./scripts/edit-config.sh      # Edit config (easy)
./scripts/update-config.sh    # Apply config changes
```

---

## 🎯 Quick Config Examples

### Increase Players (5 → 10)

Edit `k8s/02-configmap.yaml`:

```yaml
max-players=10
```

Then: `./scripts/update-config.sh`

### Change to Survival Mode

```yaml
gamemode=survival
difficulty=normal
```

### Better Performance

```yaml
view-distance=8
max-players=3
```

---

## 📚 Full Documentation

- **Configuration Guide:** `~/bedrock-container/docs/CONFIGURATION.md`
- **Complete Manual:** `~/bedrock-container/README.md`

---

## 🆘 Help

**Server won't start?**

```bash
./scripts/logs.sh -n 100
```

**Changes not applying?**

```bash
./scripts/restart.sh
```

**Need to restore?**

```bash
ls -lht ~/bedrock-backups/
./scripts/restore.sh ~/bedrock-backups/[filename]
```
