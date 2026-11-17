# Disaster Failback Runbook

## Post-Incident Restoration Procedure

### 1. Primary Region Health Verification
Before initiating failback, verify that the Primary Region (East US 2) is 100% operational and healthy:
```bash
az aks get-credentials --resource-group rg-dr-primary-eastus2 --name aks-dr-primary-eastus2 --overwrite-existing
kubectl get nodes
kubectl get pods -n ecommerce
curl -s http://<PRIMARY_INGRESS_IP>/healthz
```

### 2. State & Data Synchronization (Failback Sync)
1. Flush in-flight transactions from Secondary.
2. If using Velero with PVCs:
   - Take snapshot/backup of Secondary:
     ```bash
     velero backup create ecommerce-failback-sync --include-namespaces ecommerce
     ```
   - Restore delta into Primary:
     ```bash
     az aks get-credentials --resource-group rg-dr-primary-eastus2 --name aks-dr-primary-eastus2 --overwrite-existing
     velero restore create --from-backup ecommerce-failback-sync
     ```

### 3. Graceful Front Door Traffic Return
1. Ensure Primary ingress `/healthz` returns `HTTP 200 OK`.
2. Azure Front Door health probe automatically detects 3 consecutive successful probes (30 seconds).
3. Because Primary Origin has **Priority 1** and Secondary Origin has **Priority 2**, Front Door automatically routes new user sessions back to East US 2.
4. Scale down Secondary cluster back to 1 minimal node (Warm Standby) to optimize costs:
   ```bash
   az aks get-credentials --resource-group rg-dr-secondary-westus3 --name aks-dr-secondary-westus3 --overwrite-existing
   kubectl scale deployment ecommerce-web -n ecommerce --replicas=1
   ```

### 4. Close Incident
- Generate post-mortem report.
- Archive validation logs into `reports/`.
