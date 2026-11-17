#!/usr/bin/env bash
# Velero Cross-Region Backup and Restore Verification Script

set -euo pipefail

BACKUP_NAME="${1:-ecommerce-hourly-latest}"
TARGET_NAMESPACE="${2:-ecommerce}"

echo "=========================================================="
echo "   VELERO RESTORE VERIFICATION ON SECONDARY AKS CLUSTER   "
echo "=========================================================="

echo "Step 1: Checking Velero backup existence in GRS Blob storage..."
velero backup get "$BACKUP_NAME"

echo "Step 2: Checking PVC and Pod status in namespace: $TARGET_NAMESPACE..."
kubectl get pods -n "$TARGET_NAMESPACE" -o wide
kubectl get pvc -n "$TARGET_NAMESPACE"
kubectl get deployments -n "$TARGET_NAMESPACE"

echo "Step 3: Validating Persistent Volume status..."
PVC_STATUS=$(kubectl get pvc -n "$TARGET_NAMESPACE" -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
if [ "$PVC_STATUS" == "Bound" ]; then
    echo -e "\033[0;32m[PASS] PersistentVolumeClaim is BOUND to restored storage volume.\033[0m"
else
    echo -e "\033[0;33m[WARN] PersistentVolumeClaim status: $PVC_STATUS\033[0m"
fi

echo "Step 4: Testing application HTTP response..."
kubectl run curl-test --rm -it --restart=Never --image=curlimages/curl -- curl -s http://ecommerce-service."$TARGET_NAMESPACE".svc.cluster.local:80/healthz || true
echo "=========================================================="
