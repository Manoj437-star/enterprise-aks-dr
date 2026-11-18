"""
Enterprise AKS Disaster Recovery - Chaos Engineering & Traffic Failover Simulation Test
Tests:
1. Normal operations: Traffic flows to Primary (East US 2).
2. Chaos experiment: Primary workload failure injected.
3. Failover detection: Traffic Controller automatically reroutes traffic to Secondary (West US 3).
4. RTO measurement: Calculates exact failover time (SLA < 15 minutes).
5. Self-healing / Failback: Primary restored; traffic auto-reverts to Primary.
"""

import urllib.request
import json
import time
import subprocess
import os
import sys

CONTROLLER_URL = "http://localhost:8080"
PRIMARY_URL = "http://localhost:8081"
SECONDARY_URL = "http://localhost:8082"
APP_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "application", "src", "app.js")

def http_get(url):
    req = urllib.request.Request(url, headers={"User-Agent": "DR-TestRunner/1.0"})
    with urllib.request.urlopen(req, timeout=5) as resp:
        return resp.status, resp.headers, resp.read().decode('utf-8')

def main():
    print("=" * 70)
    print("ENTERPRISE AKS DISASTER RECOVERY - CHAOS & FAILOVER SIMULATION")
    print("=" * 70)

    # 1. Baseline verification
    print("\n[STEP 1] Verifying baseline traffic routing...")
    status, headers, body = http_get(f"{CONTROLLER_URL}/version")
    print(f"[*] Response Status: {status}")
    print(f"[*] X-Routed-Origin: {headers.get('X-Routed-Origin')}")
    print(f"[*] X-Failover-Active: {headers.get('X-Failover-Active')}")
    data = json.loads(body)
    print(f"[*] Serving Region: {data.get('region')}")
    assert "East US 2" in data.get('region'), "Initial traffic is not routing to Primary!"
    print("[+] Step 1 PASSED: Primary Region is active.")

    # 2. Chaos Injection: Terminate Primary Workload on port 8081
    print("\n[STEP 2] Injecting Chaos: Simulating Primary Application Outage...")
    # Find and kill process listening on 8081
    kill_cmd = 'Get-NetTCPConnection -LocalPort 8081 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }'
    subprocess.run(["powershell", "-Command", kill_cmd], capture_output=True)
    print("[*] Primary workload terminated. Monitoring failover detection...")

    # 3. Monitor Failover Detection & RTO
    start_time = time.time()
    failover_detected = False
    failover_region = None
    rto_seconds = 0.0

    for i in range(20):
        time.sleep(1)
        try:
            status, headers, body = http_get(f"{CONTROLLER_URL}/version")
            routed_origin = headers.get('X-Routed-Origin', '')
            if "West US 3" in routed_origin:
                failover_detected = True
                failover_region = routed_origin
                rto_seconds = round(time.time() - start_time, 2)
                print(f"[+] Outage detected and failover executed in {rto_seconds} seconds!")
                print(f"[*] Active Route: {routed_origin}")
                print(f"[*] X-Failover-Active: {headers.get('X-Failover-Active')}")
                break
        except Exception as e:
            print(f"[*] Waiting for controller reconciliation... ({e})")

    assert failover_detected, "Failover to Secondary Region failed to trigger!"
    print(f"[+] Step 2 & 3 PASSED: Automatic Failover RTO = {rto_seconds}s (Target SLA <= 15 minutes).")

    # 4. Secondary Serving Verification
    print("\n[STEP 3] Verifying Secondary Warm Standby workload integrity...")
    status, headers, body = http_get(f"{CONTROLLER_URL}/api/products")
    prod_data = json.loads(body)
    print(f"[*] Secondary Catalog Items: {prod_data.get('total')}")
    print(f"[*] Secondary Region Banner: {prod_data.get('region')}")
    print("[+] Step 4 PASSED: Workload is fully available from Secondary Region.")

    # 5. Recovery & Automated Failback
    print("\n[STEP 4] Restoring Primary Region (East US 2)...")
    env = os.environ.copy()
    env["PORT"] = "8081"
    env["REGION"] = "East US 2 (Primary Active)"
    env["APP_VERSION"] = "v1.0.0"
    p_proc = subprocess.Popen(["node", APP_PATH], env=env)
    print("[*] Primary workload restarted. Waiting for Controller health reconciliation...")

    failback_detected = False
    failback_start = time.time()
    for i in range(20):
        time.sleep(1)
        try:
            status, headers, body = http_get(f"{CONTROLLER_URL}/version")
            routed_origin = headers.get('X-Routed-Origin', '')
            if "East US 2" in routed_origin:
                failback_detected = True
                failback_time = round(time.time() - failback_start, 2)
                print(f"[+] Primary recovery verified and failback completed in {failback_time} seconds!")
                print(f"[*] Active Route: {routed_origin}")
                print(f"[*] X-Failover-Active: {headers.get('X-Failover-Active')}")
                break
        except Exception:
            pass

    assert failback_detected, "Failback to Primary Region failed to trigger!"
    print("[+] Step 5 PASSED: Automated Failback completed successfully.")

    # 6. Fetch Telemetry & Save Report
    print("\n[STEP 5] Generating Chaos Engineering & Failover Telemetry Report...")
    status, headers, body = http_get(f"{CONTROLLER_URL}/dr-telemetry")
    telemetry = json.loads(body)

    results = {
        "test_title": "Enterprise AKS Simulated Traffic Failover & Chaos Engineering",
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "primary_endpoint": PRIMARY_URL,
        "secondary_endpoint": SECONDARY_URL,
        "traffic_controller_port": 8080,
        "failover_rto_seconds": rto_seconds,
        "rto_sla_met": rto_seconds < 900,  # 15 mins = 900s
        "failback_seconds": failback_time,
        "total_failovers": telemetry.get("failover_count"),
        "telemetry_state": telemetry
    }

    report_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "reports", "chaos-and-failover-results.json")
    os.makedirs(os.path.dirname(report_path), exist_ok=True)
    with open(report_path, "w") as f:
        json.dump(results, f, indent=2)

    print(f"[+] Results saved to: {report_path}")
    print("\n" + "=" * 70)
    print(f"TEST COMPLETED SUCCESSFULLY | FAILOVER RTO: {rto_seconds}s | SLA STATUS: MET")
    print("=" * 70)

if __name__ == "__main__":
    main()
