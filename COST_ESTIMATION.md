# Cost Estimation and Budget Optimization – Enterprise AKS Disaster Recovery POC

## 1. Executive Summary

This document outlines the granular cost breakdown and financial optimization strategy for the Enterprise Multi-Region AKS Disaster Recovery Proof of Concept (POC).

- **Primary Region:** East US 2
- **Secondary Region:** West US 3
- **Architecture Model:** Active-Passive Multi-Region
- **Target Audience:** DevOps Engineers, Cloud Architects, and FinOps Teams.

> **Key Takeaway for DevOps Interviews (Interview Tip):**  
> In enterprise environments, Multi-Region Active-Active architectures can double or triple infrastructure spend. For an Active-Passive architecture with an RPO of 5 minutes and RTO of 15 minutes, we balance **Cost vs Availability** by keeping the Secondary cluster "Warm" (minimal 1-node footprint for instant ingress/pod readiness) rather than "Hot" (full scale) or "Cold" (destroy and rebuild from Terraform, which takes 18–25 minutes and violates the 15-minute RTO).

---

## 2. Granular Cost Breakdown by Component

The pricing below is based on Azure US East 2 & West US 3 standard rates (Pay-As-You-Go).

| Service Component | Tier / SKU Details | Quantity / Configuration | Hourly Burn Rate (USD) | Estimated Monthly Cost (USD) | Interview / Architecture Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AKS Control Plane** | Free Tier (`free`) | 2 Clusters (Primary + Secondary) | $0.00 / hr | $0.00 | Free tier management SLA is 99.5%, sufficient for POC. Standard Uptime SLA ($0.10/hr) is used only in Production. |
| **Primary AKS Worker Nodes** | `Standard_B2s` (2 vCPU, 4 GiB) or `Standard_D2s_v5` (2 vCPU, 8 GiB) | 1 Node in East US 2 | ~$0.0416 - $0.096 / hr | ~$30.37 - $70.08 | Fits within the 4 vCPU regional subscription quota. Capable of hosting CoreDNS, Ingress, and the sample app. |
| **Secondary AKS Worker Nodes** | `Standard_B2s` (2 vCPU, 4 GiB) or `Standard_D2s_v5` (2 vCPU, 8 GiB) | 1 Node in West US 3 | ~$0.0416 - $0.096 / hr | ~$30.37 - $70.08 | Kept provisioned as a "Warm Standby" to satisfy the 15-minute RTO requirement. |
| **OS Disks (Node Storage)** | Standard SSD (`E10`, 128 GB) | 2 Disks (1 per cluster node) | ~$0.018 / hr | ~$13.00 | Standard SSD provides adequate IOPS for POC workloads at half the cost of Premium SSD. |
| **Azure Container Registry (ACR)** | Standard vs Premium (Geo-Replication) | 1 Registry + 1 Replica | ~$0.022 / hr (Standard) vs ~$0.138 / hr (Premium Geo-Rep) | ~$16.00 (Std) / ~$100.00 (Prem) | Premium tier provides native Active-Active geo-replication across East US 2 and West US 3. For budget testing, Standard tier can be used with automated sync. |
| **Azure Front Door** | Premium vs Standard Profile | 1 Profile + 1 Endpoint + WAF | ~$0.048 / hr (Standard) vs ~$0.458 / hr (Premium) | ~$35.00 (Std) / ~$330.00 (Prem) | Front Door Premium includes Managed WAF rules and Bot protection. Standard profile covers layer-7 health probe failover for cost savings. |
| **Azure Traffic Manager** | Standard DNS Profile | 1 Profile + 2 Endpoints | ~$0.001 / hr | ~$1.26 | First 1M DNS queries are free. Endpoint health checks cost ~$0.36/endpoint/mo. |
| **Storage Account (Velero)** | Standard General Purpose v2 (GRS / RA-GRS) | 1 Account (Hot Tier, ~5 GB) | ~$0.001 / hr | ~$0.50 | Geo-Redundant Storage (GRS) replicates Velero backups asynchronously from East US 2 to West US 3. |
| **Log Analytics & Monitor** | Pay-as-you-go (Per GB ingestion) | Ingestion < 5 GB / month | $0.00 / hr | $0.00 (Free 5 GB allowance) | Azure provides first 5 GB/month free data ingestion per billing account. |
| **Public IP Addresses** | Standard SKU Public IP | 2 IPs (1 per Ingress Controller) | ~$0.010 / hr | ~$7.30 | Required for external ingress endpoints reached by Front Door and Traffic Manager. |

---

## 3. Total Estimated Budget Profiles

### Scenario A: Strict Budget POC (Active-Passive with Cost Controls)
- AKS: 1 Node Primary (`Standard_B2s`), 1 Node Secondary (`Standard_B2s`)
- Registry: ACR Standard (or short-term Premium)
- Front Door: Standard (or Premium tested during active 8-hour window)
- Storage: Standard GRS Blob (< 5 GB)
- **Hourly Cost:** **~$0.18 – $0.25 / hour** (approx. ₹15 – ₹21 per hour)
- **Active 10-Hour Testing Window Cost:** **~$2.50 USD (₹210 INR)**
- **Monthly Cost (if left running continuously):** **~$125 – $150 USD**

### Scenario B: Full Enterprise Spec (Front Door Premium + ACR Geo-Replication)
- AKS: 1 Node Primary, 1 Node Secondary
- Registry: ACR Premium with West US 3 Geo-Replication
- Global Entry: Azure Front Door Premium with WAF Ruleset
- **Hourly Cost:** **~$0.65 – $0.75 / hour** (approx. ₹55 – ₹62 per hour)
- **Active 10-Hour Testing Window Cost:** **~$6.50 – $7.50 USD (₹550 – ₹625 INR)**
- **Monthly Cost (if left running continuously):** **~$480 – $520 USD**

---

## 4. Cost-Saving Strategies and Guardrails

1. **Warm Standby vs Cold Standby Decision (Interview Gold):**
   - *Cold Standby:* Secondary cluster is 0 nodes or deleted. Recovery requires `terraform apply` to provision the secondary AKS cluster.  
     *Problem:* AKS provisioning takes **18 to 25 minutes**. This strictly **violates the 15-minute RTO** business requirement.
   - *Warm Standby:* Secondary cluster has 1 minimum-size node (`Standard_B2s`), Flux v2 already running, and namespaces pre-created. Recovery requires only DNS failover and pod scaling/restore.  
     *Result:* Recovery completes in **< 3 minutes**, beating the 15-minute RTO while adding only ~$30/month in compute cost.

2. **Cluster Auto-Shutdown / Stop Feature:**
   - In AKS, we can use `az aks stop` on clusters when not actively testing.
   - While stopped, compute costs drop to **$0.00**; you only pay for storage disks.
   - Command:
     ```bash
     az aks stop --resource-group rg-dr-primary-eastus2 --name aks-dr-primary-eastus2
     az aks start --resource-group rg-dr-primary-eastus2 --name aks-dr-primary-eastus2
     ```

3. **Cloud-Native Image Builds (`az acr build`):**
   - Eliminates the need for running Docker Desktop or paying third-party licensing on Windows machines.

4. **Teardown Automation:**
   - A single automated destroy plan will be provided so you can tear down all resources immediately after validation tests are complete.
