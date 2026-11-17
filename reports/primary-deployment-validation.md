# Primary Region (East US 2) Deployment Validation Report

**Deployment Date:** 2026-11-17  
**Cluster Name:** `aks-dr-primary-eastus2`  
**Azure Region:** East US 2  
**Resource Group:** `rg-dr-primary-eastus2`  
**Subscription ID:** `634797e9-e825-4199-b9c1-40fc24dc3400`  
**Overall Status:** :white_check_mark: **100% HEALTHY & OPERATIONAL**

---

## 1. Executive Summary & Architecture State

The Primary Region (Active) infrastructure for the Enterprise AKS Multi-Region Disaster Recovery POC has been successfully provisioned, configured, and fully verified. 

- **17 Azure Resources** deployed via modular Terraform.
- **Single-node cost-conscious cluster** (`Standard_D2s_v6`, 2 vCPU, 8 GiB RAM) within the subscription's 4 vCPU regional quota.
- **Enterprise ACR integration** verified with Azure Managed Identity (`AcrPull`).
- **Cloud-native Workload** deployed with 2 replicas, actively serving live traffic on public DNS.
- **Log Analytics & Metric Alerts** attached with automated Action Group emailing `manojdeep.jaiswal@gmail.com`.
- **Velero GRS Storage** container (`velero-backups`) ready for cross-region replication.
- **Flux v2 GitOps prerequisites** validated (`flux check --pre`).

---

## 2. Cluster Health & Workload Verification

### A. Kubernetes Node Status
```text
NAME                             STATUS   ROLES    AGE   VERSION   INTERNAL-IP   OS-IMAGE             CONTAINER-RUNTIME
aks-system-93138604-vmss000000   Ready    <none>   35m   v1.36.5   10.240.1.4    Ubuntu 24.04.5 LTS   containerd://2.3.7-4
```

### B. Core System Pods (`kube-system`)
All 17 control-plane and addon pods are `Running` with 0 restarts:
- `coredns` (2/2 replicas active)
- `ama-logs` & `ama-logs-rs` (Azure Monitor Container Insights)
- `azure-cns`, `azure-ip-masq-agent`, `azure-npm` (Azure CNI Networking)
- `csi-azuredisk-node`, `csi-azurefile-node` (Azure Storage CSI drivers)
- `konnectivity-agent` (API server tunneling)
- `metrics-server` (Horizontal Pod Autoscaling ready)

### C. Application Pods & Service (`ecommerce`)
```text
NAME                                 READY   STATUS    RESTARTS   IP            NODE
pod/ecommerce-web-76d75f7f85-dtnrm   1/1     Running   0          10.240.1.14   aks-system-93138604-vmss000000
pod/ecommerce-web-76d75f7f85-g9jnt   1/1     Running   0          10.240.1.19   aks-system-93138604-vmss000000

NAME                        TYPE           EXTERNAL-IP      PORT(S)
service/ecommerce-service   LoadBalancer   132.196.184.41   80:32337/TCP
```

---

## 3. Live Traffic & Endpoints Verification

The application is reachable both via Azure Load Balancer VIP and its public FQDN:
- **Public VIP:** `http://132.196.184.41`
- **Public FQDN:** `http://ecommerce-dr-primary-eastus2.eastus2.cloudapp.azure.com`

### Endpoint Probes Output:
| Endpoint | HTTP Status | Response Payload |
|---|---|---|
| `/healthz` | `200 OK` | `{"status":"HEALTHY","region":"East US 2 (Primary Active)","timestamp":"2026-11-17T12:51:11.643Z"}` |
| `/version` | `200 OK` | `{"version":"v1.0.0","region":"East US 2 (Primary Active)","hostname":"ecommerce-web-76d75f7f85-dtnrm","uptimeSeconds":1244}` |
| `/readyz` | `200 OK` | `{"status":"READY","region":"East US 2 (Primary Active)"}` |
| `/livez` | `200 OK` | `{"status":"ALIVE","region":"East US 2 (Primary Active)"}` |
| `/` (UI) | `200 OK` | HTML rendered with **Primary Active (Blue Banner #0078D4)** & Product Catalog |

---

## 4. Key Technical Decisions & Interview Guide (Hinglish + English)

### Q1: Why did we use `Standard_D2s_v6` instead of `Standard_B2s` or `D4s_v5`?
> **English:** In East US 2, our active Pay-As-You-Go subscription has a regional quota limit of 4 vCPUs for standard VM families. Azure Container Service policy in East US 2 specifically disallows `Standard_B2s` for AKS node pools. `Standard_D2s_v6` provides 2 vCPUs and 8 GiB RAM, which gives stable performance for AKS system agents while consuming only 2 of our 4 vCPUs. This leaves the remaining 2 vCPUs free for our Secondary Region (West US 3) cluster.
>
> **Hinglish:** *East US 2 region mein subscription quota 4 vCPUs limit tha aur Azure ne B2s size ko AKS ke liye reject kar diya tha. Humne `Standard_D2s_v6` (2 vCPU, 8GB RAM) choose kiya taaki system pods smoothly chalein aur remaining 2 vCPUs secondary region (West US 3) ke standby cluster ke liye bache rahein.*

### Q2: How did AKS authenticate with Azure Container Registry (ACR)?
> **English:** We implemented zero-secret cloud-native authentication using AKS Managed Identity. The AKS Kubelet Managed Identity was granted the `AcrPull` built-in role over the ACR resource scope (`acrdreastus2poc`). Pods pull images seamlessly without any Kubernetes imagePullSecrets or stored tokens.
>
> **Hinglish:** *Humne koi password ya secret create nahi kiya. AKS ke Kubelet Managed Identity ko ACR par `AcrPull` role assign kiya. Kubelet automatically Azure AD se token fetch karta hai aur image pull kar leta hai.*

### Q3: How did we handle Azure Load Balancer Public IP binding and RBAC?
> **English:** When attaching a public IP via Kubernetes Service annotations (`service.beta.kubernetes.io/azure-dns-label-name: ecommerce-dr-primary-eastus2`), Azure AKS cloud-provider dynamically allocates an Azure Standard Public IP within the AKS managed node resource group (`MC_...`) and registers the DNS label with Azure DNS. Furthermore, granting `Network Contributor` to the cluster identity enables cross-resource-group public IP bindings without permission errors.
>
> **Hinglish:** *Service annotation `service.beta.kubernetes.io/azure-dns-label-name` use karke AKS ne automatically Azure public IP create ki aur public DNS record set kar diya (`ecommerce-dr-primary-eastus2.eastus2.cloudapp.azure.com`). Isse Front Door aur Traffic Manager ko direct DNS endpoint mil jata hai.*

---

## 5. Next Steps (Pending User Approval)

1. **Deploy Secondary Region (West US 3 - Warm Standby):**
   - Resource Group: `rg-dr-secondary-westus3`
   - Single-node AKS cluster (`Standard_D2s_v6` in West US 3).
   - Log Analytics Workspace & Monitoring Alerts.
   - Passive workload deployment (`replicas: 1` or `replicas: 0`).
2. **Dual-Layer Traffic Routing:**
   - Configure Azure Front Door & Traffic Manager routing between East US 2 (Priority 1) and West US 3 (Priority 2).
3. **Velero Backup Schedule & Cross-Region Restore Validation.**
4. **Automated DR Test Engine Execution.**
