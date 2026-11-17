# Velero Kubernetes Data Protection Runbook

## Overview
Velero provides disaster recovery and namespace migration for Kubernetes workloads by backing up resource definitions and volume snapshots to Azure Blob Storage (GRS).

## Key Commands
### 1. Install Velero via Helm
```bash
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update
helm install velero vmware-tanzu/velero --namespace velero --create-namespace -f velero/install/values.yaml
```

### 2. Take Manual Backup of Primary E-Commerce Namespace
```bash
velero backup create ecommerce-manual-backup --include-namespaces ecommerce --snapshot-volumes
velero backup describe ecommerce-manual-backup
```

### 3. Restore to Secondary Cluster
Switch kubectl context to Secondary cluster:
```bash
az aks get-credentials --resource-group rg-dr-secondary-westus3 --name aks-dr-secondary-westus3 --overwrite-existing
velero restore create --from-backup ecommerce-manual-backup
velero restore get
kubectl get pods -n ecommerce
```
