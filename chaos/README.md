# Azure Chaos Studio Experiments & Safety Runbook

## Overview
Chaos Engineering intentionally injects controlled failures into our primary AKS infrastructure to empirically validate automated failover to the secondary region.

## Safety Guardrails
1. **Scope:** Only targeted resources in `rg-dr-primary-eastus2` are ever selected.
2. **Blast Radius:** No shared or production subscription resources are touched.
3. **Rollback:** Every experiment has an explicit 5-minute timeout (`PT5M`), after which Azure Chaos Studio automatically restores the target to normal operation.

## Experiment Catalog
1. **Experiment 1 (Node Failure):** Abrupt shutdown of the primary cluster's VMSS instance to test pod rescheduling and Front Door probe failure detection.
2. **Experiment 2 (Network Latency):** Injects 500ms delay with 10ms jitter on ingress controllers to test timeout handling and degraded health failover.
3. **Experiment 3 (Pod Loss):** Evicts and terminates pods continuously in the `ecommerce` namespace to test PodDisruptionBudgets and GitOps self-healing.
