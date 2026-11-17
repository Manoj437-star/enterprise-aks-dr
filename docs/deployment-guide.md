# Multi-Region AKS Disaster Recovery: End-to-End Deployment Guide

## 1. Prerequisites Checklist
- Azure CLI authenticated (`az login`) with Owner or Contributor + User Access Administrator on subscription.
- Terraform v1.5+ installed.
- Kubectl v1.30+ installed.
- Flux CLI v2.10+ installed.
- Python 3.11+ installed.

---

## 2. Step-by-Step Provisioning Sequence

### Step 2.1: Primary Region Infrastructure (East US 2)
```bash
cd d:\DevOps\enterprise-aks-dr\terraform\primary
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"
```
Outputs captured:
- Primary Ingress FQDN
- ACR Login Server (`acrdreastus2poc.azurecr.io`)
- Storage Account (`stdreastus2backup`)

### Step 2.2: Configure Kubectl Context for Primary
```bash
az aks get-credentials --resource-group rg-dr-primary-eastus2 --name aks-dr-primary-eastus2 --overwrite-existing
kubectl get nodes
kubectl get pods -A
```

### Step 2.3: Build & Push E-Commerce Application to ACR
```bash
cd d:\DevOps\enterprise-aks-dr
az acr build --registry acrdreastus2poc --image ecommerce-app:v1.0.0 ./application
```

### Step 2.4: Deploy Workload via GitOps (Flux v2)
Bootstrap Flux v2 or apply Kustomize overlay directly:
```bash
kubectl apply -k gitops/clusters/primary
kubectl get pods -n ecommerce -w
```

### Step 2.5: Secondary Region Infrastructure (West US 3 - Warm Standby)
```bash
cd d:\DevOps\enterprise-aks-dr\terraform\secondary
terraform init
terraform plan -out=tfplan -var="acr_id=<ACR_RESOURCE_ID>"
terraform apply "tfplan"
```

### Step 2.6: Configure Kubectl Context for Secondary
```bash
az aks get-credentials --resource-group rg-dr-secondary-westus3 --name aks-dr-secondary-westus3 --overwrite-existing
kubectl apply -k gitops/clusters/secondary
kubectl get pods -n ecommerce
```

### Step 2.7: Deploy Global Traffic Management (Azure Front Door)
```bash
cd d:\DevOps\enterprise-aks-dr\terraform\examples\global-traffic
terraform init
terraform plan -out=tfplan -var="primary_ingress_host=<PRIMARY_FQDN>" -var="secondary_ingress_host=<SECONDARY_FQDN>"
terraform apply "tfplan"
```
