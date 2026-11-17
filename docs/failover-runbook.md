# Disaster Failover Runbook

## Emergency Activation Procedure

### 1. Disaster Event Trigger
- Condition: Primary Region (East US 2) total network loss, Azure datacenter outage, or sustained node failure > 2 minutes.
- Incident Commander notifies DevOps on-call.

### 2. Automatic Traffic Failover (Front Door)
- Azure Front Door health probe checks `/healthz` on primary origin every 10 seconds.
- After 3 failed probes (30 seconds), Front Door marks East US 2 as **Unhealthy**.
- Front Door automatically shifts 100% of incoming HTTP/HTTPS traffic to the West US 3 origin.
- Verification command:
  ```bash
  curl -s http://<FRONT_DOOR_ENDPOINT>/version | jq .
  ```
  Expected output confirms `region: "West US 3 (Secondary Warm Standby)"`.

### 3. Scaling Workload on Secondary AKS (If Necessary)
If traffic volume demands scaling:
```bash
az aks get-credentials --resource-group rg-dr-secondary-westus3 --name aks-dr-secondary-westus3 --overwrite-existing
kubectl scale deployment ecommerce-web -n ecommerce --replicas=5
```

### 4. Data State Restoration (Velero)
If persistent state delta must be restored:
```bash
velero restore create --from-backup ecommerce-hourly-latest
velero restore describe <RESTORE_NAME>
kubectl get pvc -n ecommerce
```

### 5. Automated Validation
Run the automated DR script:
```bash
python scripts/dr_validation.py --global-url http://<FRONT_DOOR_ENDPOINT>
```
Review generated `reports/dr-summary.md` to ensure RTO $\le 15\text{ minutes}$ is satisfied.
