#!/usr/bin/env bash
# Real-Time Failover Traffic Probe
# Continuously queries the Front Door endpoint to observe the switch from East US 2 to West US 3

set -euo pipefail

TARGET_URL="${1:-http://ecommerce-ingress-primary-eastus2.eastus2.cloudapp.azure.com}"
INTERVAL="${2:-2}"

echo "Starting continuous failover probe on: $TARGET_URL"
echo "Press [CTRL+C] to stop."
echo "Timestamp | HTTP Status | Response Time | Serving Region"
echo "--------------------------------------------------------"

while true; do
    TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%SZ")
    RESPONSE=$(curl -s -w "\n%{http_code} %{time_total}" --connect-timeout 3 "$TARGET_URL/version" || echo -e '{"region":"FAILED"}\n000 0.000')
    BODY=$(echo "$RESPONSE" | head -n -1)
    STATS=$(echo "$RESPONSE" | tail -n 1)
    HTTP_CODE=$(echo "$STATS" | awk '{print $1}')
    TIME_TOTAL=$(echo "$STATS" | awk '{print $2}')
    
    REGION=$(echo "$BODY" | grep -o '"region":"[^"]*' | cut -d'"' -f4 || echo "N/A")
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        if [[ "$REGION" =~ [eE]ast ]]; then
            COLOR="\033[0;34m" # Blue for East
        else
            COLOR="\033[0;32m" # Green for West
        fi
        echo -e "${TIMESTAMP} | HTTP ${HTTP_CODE} | ${TIME_TOTAL}s | ${COLOR}${REGION}\033[0m"
    else
        echo -e "${TIMESTAMP} | \033[0;31mHTTP ${HTTP_CODE}\033[0m | ${TIME_TOTAL}s | OUTAGE"
    fi
    sleep "$INTERVAL"
done
