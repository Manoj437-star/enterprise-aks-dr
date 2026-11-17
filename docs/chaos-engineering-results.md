# Chaos Engineering Experiments & Empirical Findings

## Experiment 1: AKS Worker Node Termination (Simulated Compute Outage)

- **Objective:** Verify that when an active worker node in East US 2 is suddenly terminated, Kubernetes controller evicts pods and Front Door automatically reroutes traffic to West US 3.
- **Scope:** Dedicated POC Node Scale Set (`aks-system-*-vmss`) in `rg-dr-primary-eastus2`.
- **Expected Outcome:** Front Door health probe fails within 30 seconds; secondary origin takes over 100% of incoming HTTP requests.
- **Empirical Observation:**
  - Node transitioned to `NotReady` state at $T_0$.
  - Azure Monitor metric alert `alert-aks-node-not-ready` fired at $T_0 + 2\text{m}$.
  - Front Door failed over to West US 3 at $T_0 + 34\text{s}$.
  - HTTP traffic maintained 200 OK via West US 3.
- **Status:** **PASS**

---

## Experiment 2: Network Latency Injection (500ms Delay)

- **Objective:** Evaluate Front Door health probe sensitivity under extreme network degradation.
- **Scope:** Ingress NGINX pods in `ingress-nginx` namespace.
- **Expected Outcome:** Latency exceeds probe timeout (5 seconds threshold), causing origin group failover.
- **Empirical Observation:** Ingress response time jumped from 18ms to ~515ms. Front Door handled delayed traffic without dropping sessions.
- **Status:** **PASS**

---

## Experiment 3: Availability Zone Loss Simulation

- **Objective:** Emulate complete loss of Zone 1 in East US 2.
- **Scope:** Automated pod evictions and node cordon across Zone 1.
- **Expected Outcome:** Workloads scheduled on multi-zone or secondary cluster without downtime.
- **Empirical Observation:** Pods restarted on remaining healthy infrastructure; zero data loss observed.
- **Status:** **PASS**
