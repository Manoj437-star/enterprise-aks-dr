# Enterprise AKS Disaster Recovery POC

> **Multi-Region Failover, GitOps (Flux v2), Kubernetes Data Protection (Velero), and Chaos Engineering on Azure**

[![Azure](https://img.shields.io/badge/Cloud-Microsoft%20Azure-0078D4?logo=microsoftazure)](https://azure.microsoft.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)](https://www.terraform.io/)
[![Flux v2](https://img.shields.io/badge/GitOps-Flux%20v2-5468FF?logo=flux)](https://fluxcd.io/)
[![Velero](https://img.shields.io/badge/Backup-Velero-195982?logo=vmware)](https://velero.io/)

---

## 📌 Executive Summary

This repository contains the production-grade, modular Proof of Concept (POC) for an **Active-Passive Multi-Region Disaster Recovery** solution for enterprise applications hosted on **Azure Kubernetes Service (AKS)**.

- **Primary Region:** East US 2 (`eastus2`)
- **Secondary Region:** West US 3 (`westus3`)
- **Recovery Point Objective (RPO):** $\le 5$ Minutes
- **Recovery Time Objective (RTO):** $\le 15$ Minutes

---

## 📂 Project Repository Structure

```
enterprise-aks-dr/
├── README.md                      # Main project documentation and quickstart
├── ARCHITECTURE.md                # Comprehensive architectural design & diagrams
├── PROJECT_PLAN.md                # 11-phase implementation roadmap & milestones
├── COST_ESTIMATION.md             # Detailed budget breakdown, FinOps & quota analysis
│
├── terraform/                     # Infrastructure-as-Code modules
│   ├── modules/
│   │   ├── aks/                   # AKS cluster module with Managed Identity & Azure CNI
│   │   ├── networking/            # VNets, subnets, NSGs, and IP allocation
│   │   ├── acr/                   # Container Registry with geo-replication
│   │   ├── storage/               # GRS Blob Storage for Velero backups
│   │   ├── frontdoor/             # Azure Front Door Premium / Standard + WAF
│   │   ├── traffic-manager/       # Azure Traffic Manager DNS failover
│   │   └── monitoring/            # Log Analytics and Azure Monitor integration
│   ├── primary/                   # East US 2 Terraform root module
│   ├── secondary/                 # West US 3 Terraform root module
│   └── examples/                  # Sample variable configurations
│
├── application/                   # Sample E-Commerce containerized web app
│   ├── Dockerfile                 # Multi-stage lightweight container build
│   ├── src/                       # Application source with healthz, readyz, region tags
│   └── README.md
│
├── gitops/                        # Flux v2 GitOps manifests & overlays
│   ├── base/                      # Base Kubernetes resources
│   ├── clusters/
│   │   ├── primary/               # East US 2 overlay
│   │   └── secondary/             # West US 3 overlay
│   └── README.md
│
├── kubernetes/                    # Raw Kubernetes manifests for validation
│   ├── namespace/
│   ├── deployments/
│   ├── services/
│   ├── ingress/
│   └── storage/
│
├── velero/                        # Backup and disaster recovery automation
│   ├── install/                   # Velero installation manifests & Helm values
│   ├── backup/                    # Backup schedules & on-demand jobs
│   ├── restore/                   # Secondary cluster restoration manifests
│   └── README.md
│
├── monitoring/                    # Observability and alerts
│   ├── alerts/                    # Azure Monitor alert rules (Node, Pod, PVC)
│   ├── grafana/                   # Managed Grafana dashboard JSON export
│   └── README.md
│
├── chaos/                         # Chaos engineering experiment definitions
│   ├── experiments/               # Node failure, latency, and pod eviction JSON/YAML
│   └── README.md
│
├── scripts/                       # Automation and DR validation engines
│   ├── dr_validation.py           # Automated Python DR validation script
│   ├── health_check.sh            # Ingress and pod health verification
│   ├── failover_check.sh          # Traffic failover latency testing
│   └── restore_validation.sh      # Velero secondary restore verification
│
├── reports/                       # Generated execution reports & validation summaries
│   └── .gitkeep
│
└── docs/                          # Detailed operational runbooks
    ├── architecture.md
    ├── deployment-guide.md
    ├── failover-runbook.md
    ├── failback-runbook.md
    ├── troubleshooting.md
    ├── rpo-rto-validation.md
    └── chaos-engineering-results.md
```

---

## 🚀 Quick Navigation

- 📐 [Detailed Architecture & Traffic Flows](ARCHITECTURE.md)
- 🗺️ [Project Roadmap & Phase Checkpoints](PROJECT_PLAN.md)
- 💰 [Cost Estimation & FinOps Optimization](COST_ESTIMATION.md)
