#!/usr/bin/env bash
# Health Check Verification Script for Multi-Region AKS Ingress

set -euo pipefail

PRIMARY_HOST="${1:-ecommerce-ingress-primary-eastus2.eastus2.cloudapp.azure.com}"
SECONDARY_HOST="${2:-ecommerce-ingress-secondary-westus3.westus3.cloudapp.azure.com}"
GLOBAL_HOST="${3:-ecommerce-ingress-primary-eastus2.eastus2.cloudapp.azure.com}"

echo "=========================================================="
echo "   MULTI-REGION AKS APPLICATION HEALTH CHECK              "
echo "=========================================================="

check_endpoint() {
    local label="$1"
    local url="$2"
    echo -n "Checking $label ($url)... "
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" || echo "000")
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 400 ]; then
        echo -e "\033[0;32m[HEALTHY - HTTP $http_code]\033[0m"
    else
        echo -e "\033[0;31m[UNHEALTHY - HTTP $http_code]\033[0m"
    fi
}

check_endpoint "Primary East US 2" "http://${PRIMARY_HOST}/healthz"
check_endpoint "Secondary West US 3" "http://${SECONDARY_HOST}/healthz"
check_endpoint "Global Front Door Ingress" "http://${GLOBAL_HOST}/healthz"
echo "=========================================================="
