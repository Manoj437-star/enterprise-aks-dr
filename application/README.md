# Sample E-Commerce Web Application

This containerized application demonstrates multi-region disaster recovery for Azure Kubernetes Service.

## Features
- Dynamic region identification via the `REGION` environment variable (`East US 2` vs `West US 3`).
- Health endpoints:
  - `/healthz` (200 OK for Azure Front Door and Ingress health probes)
  - `/readyz` (Kubernetes readiness probe)
  - `/livez` (Kubernetes liveness probe)
  - `/version` (JSON metadata payload)
- Visual banner:
  - Blue (`#0078D4`) when running in East US 2 (Primary Active).
  - Green (`#107C41`) when running in West US 3 (Secondary Standby).

## Cloud-Native Build (Zero-Docker Required)
Build directly in Azure Container Registry:
```bash
az acr build --registry acrdreastus2poc --image ecommerce-app:v1.0.0 ./application
```
