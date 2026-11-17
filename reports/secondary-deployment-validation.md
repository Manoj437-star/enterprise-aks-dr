# Secondary Region (West US 3 - Warm Standby) Deployment Validation Report

**Deployment Date:** 2026-11-17  
**Cluster Name:** `aks-dr-secondary-westus3`  
**Azure Region:** West US 3  
**Resource Group:** `rg-dr-secondary-westus3`  
**Subscription ID:** `634797e9-e825-4199-b9c1-40fc24dc3400`  
**Overall Status:** :white_check_mark: **100% HEALTHY & OPERATIONAL (WARM STANDBY)**

---

## 1. Executive Summary & Architecture State

The Secondary Region (Warm Standby) infrastructure has been successfully provisioned, configured, and verified.

- **14 Azure Resources** deployed via modular Terraform (`terraform/secondary`).
- **Single-node cost-conscious cluster** (`Standard_D2s_v4`, 2 vCPU, 8 GiB RAM) consuming 2 of 4 vCPUs regional quota.
- **Cross-Region ACR integration** verified: Kubelet Managed Identity pulled container image `ecommerce-app:v1.0.0` from Primary ACR `acrdreastus2poc.azurecr.io` (East US 2) via `AcrPull`.
- **Warm Standby Workload** deployed with 1 replica, actively serving live traffic on public DNS.
- **Log Analytics & Metric Alerts** operational with automated Action Group emailing `manojdeep.jaiswal@gmail.com`.
- **Primary Region (`rg-dr-primary-eastus2`)** remains 100% untouched and healthy.

---

## 2. Verification of Required Post-Deployment Steps

| Step | Task | Status | Actual Observation |
|---|---|---|---|
| **1** | **Configure kubectl credentials** | :white_check_mark: Complete | Context `aks-dr-secondary-westus3` merged into `~/.kube/config`. |
| **2** | **Verify cluster connectivity** | :white_check_mark: Complete | Connected to API Server on Kubernetes `v1.36.5`. |
| **3** | **Check node health & readiness** | :white_check_mark: Complete | Node `aks-system-29925965-vmss000000` is **Ready** (`Standard_D2s_v4`, 2 vCPU, 8GB RAM, containerd 2.3.7). |
| **4** | **Verify system pods** | :white_check_mark: Complete | All 17 pods in `kube-system` (`coredns`, `ama-logs`, `konnectivity-agent`, `azure-cns`, `metrics-server`) are **Running** with **0 restarts**. |
| **5** | **Verify cross-region ACR pull** | :white_check_mark: Complete | Pulled `acrdreastus2poc.azurecr.io/ecommerce-app:v1.0.0` from East US 2 via Azure Managed Identity `AcrPull`. |
| **6** | **Verify application deployment & health** | :white_check_mark: Complete | Pod `ecommerce-web-76d75f7f85-mlzq9` is **Running**; Service bound to VIP `20.14.37.223` and FQDN `ecommerce-dr-secondary-westus3.westus3.cloudapp.azure.com`. |
| **7** | **Verify Log Analytics integration** | :white_check_mark: Complete | Workspace `law-aks-dr-secondary` active; Container Insights OMS agent streaming; 3 Alert rules enabled. |
| **8** | **Generate validation report** | :white_check_mark: Complete | Saved to `reports/secondary-deployment-validation.md` & `reports/secondary-terraform-outputs.json`. |

---

## 3. Cluster Telemetry & Workload Verification

### A. Kubernetes Node Status
```text
NAME                             STATUS   ROLES    AGE     VERSION   INTERNAL-IP   OS-IMAGE             CONTAINER-RUNTIME
aks-system-29925965-vmss000000   Ready    <none>   7m12s   v1.36.5   10.241.1.4    Ubuntu 24.04.5 LTS   containerd://2.3.7-4
```

### B. Core System Pods (`kube-system`)
All 17 system pods are active with 0 restarts:
- `ama-logs` & `ama-logs-rs` (Azure Monitor Container Insights)
- `azure-cns`, `azure-ip-masq-agent`, `azure-npm` (Azure CNI Networking)
- `csi-azuredisk-node`, `csi-azurefile-node` (Azure Storage CSI drivers)
- `coredns` (2/2 replicas active)
- `konnectivity-agent` (API server tunneling)
- `metrics-server` (2/2 replicas active)

### C. Application Pods & Service (`ecommerce`)
```text
NAME                                 READY   STATUS    RESTARTS   IP            NODE
pod/ecommerce-web-76d75f7f85-mlzq9   1/1     Running   0          10.241.1.16   aks-system-29925965-vmss000000

NAME                        TYPE           EXTERNAL-IP    PORT(S)
service/ecommerce-service   LoadBalancer   20.14.37.223   80:32692/TCP
```

---

## 4. Live Traffic & Endpoints Verification

The application is reachable via Azure Load Balancer VIP and public FQDN:
- **Public VIP:** `http://20.14.37.223`
- **Public FQDN:** `http://ecommerce-dr-secondary-westus3.westus3.cloudapp.azure.com`

### Endpoint Probes Output:
| Endpoint | HTTP Status | Response Payload |
|---|---|---|
| `/healthz` | `200 OK` | `{"status":"HEALTHY","region":"West US 3 (Secondary Warm Standby)","timestamp":"2026-11-17T13:40:34.608Z"}` |
| `/version` | `200 OK` | `{"version":"v1.0.0","region":"West US 3 (Secondary Warm Standby)","hostname":"ecommerce-web-76d75f7f85-mlzq9","uptimeSeconds":130}` |
| `/readyz` | `200 OK` | `{"status":"READY","region":"West US 3 (Secondary Warm Standby)"}` |
| `/livez` | `200 OK` | `{"status":"ALIVE","region":"West US 3 (Secondary Warm Standby)"}` |
| `/` (UI) | `200 OK` | HTML rendered with **Secondary Warm Standby (Green Banner #107C41)** & Product Catalog |

---

## 5. Dual-Cluster Multi-Region State

Both AKS clusters are now operational in an Active-Passive Disaster Recovery topology:

| Region | Role | Cluster Name | Public FQDN | Health Probe Status | Banner Color | Replicas |
|---|---|---|---|---|---|---|
| **East US 2** | **Primary (Active)** | `aks-dr-primary-eastus2` | `ecommerce-dr-primary-eastus2.eastus2.cloudapp.azure.com` | :white_check_mark: `200 OK` | Blue (`#0078D4`) | 2 |
| **West US 3** | **Secondary (Warm Standby)** | `aks-dr-secondary-westus3` | `ecommerce-dr-secondary-westus3.westus3.cloudapp.azure.com` | :white_check_mark: `200 OK` | Green (`#107C41`) | 1 |

---

## 6. Key Technical Decisions & Interview Guide (Hinglish + English)

### Q1: Multi-Region deployment mein cross-region ACR pulling kaise secure ki jaati hai?
> **English:** Rather than creating multiple regional ACRs or syncing images via complex webhooks for a cost-conscious POC, we utilized a single Central ACR in East US 2 (`acrdreastus2poc`). The Secondary AKS Kubelet Managed Identity was granted the `AcrPull` built-in role directly on the Primary ACR. When the Secondary AKS cluster spins up pods, it pulls images across Microsoft's high-speed private backbone network with zero Kubernetes secrets.
>
> **Hinglish:** *Interview mein batayein: POC cost aur complexity bachane ke liye humne primary region mein central ACR banaya. Secondary cluster ke Kubelet Managed Identity ko ACR par `AcrPull` role de diya. Secondary cluster ne direct Azure backbone se secure tarike se image pull kar li bina kisi Kubernetes secret ya password ke.*

### Q2: Warm Standby pattern ke kya advantages aur cost trade-offs hain?
> **English:** In a Warm Standby architecture, the secondary cluster is pre-provisioned with minimal compute capacity (1 node, 1 replica). This guarantees an RTO of <5 minutes because the cluster, networking, ingress, and node pools are already running—there is no 5-10 minute delay waiting for cluster creation. In normal operations, it costs only ~$0.096/hr. During a failover event, the Horizontal Pod Autoscaler (HPA) or cluster autoscaler scales out the node pool to handle 100% production load.
>
> **Hinglish:** *Cold Standby mein cluster disaster ke waqt banta hai jisme 10-15 minute lagte hain aur RTO miss ho sakta hai. Warm Standby mein cluster 1 node aur 1 replica ke saath ready rehta hai. Cost sirf ~$0.096/hr lagti hai, aur disaster aate hi failover seconds mein ho jata hai.*

---

## 7. Next Steps

1. **Dual-Layer Global Traffic Routing:**
   - Configure Azure Front Door & Traffic Manager routing between Primary (`ecommerce-dr-primary-eastus2...`) as Priority 1 and Secondary (`ecommerce-dr-secondary-westus3...`) as Priority 2.
2. **Velero Backup Schedule & Cross-Region Restore Validation.**
3. **Automated DR Test Engine (`scripts/dr_validation.py`) Execution.**
