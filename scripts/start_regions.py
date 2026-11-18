"""
Enterprise AKS Disaster Recovery - Local Dual-Region Mock Servers
Starts Primary (East US 2 - Port 8081) and Secondary (West US 3 - Port 8082) services.
"""

import os
import subprocess
import sys
import time

APP_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "application", "src", "app.js")

def start_primary():
    env = os.environ.copy()
    env["PORT"] = "8081"
    env["REGION"] = "East US 2 (Primary Active)"
    env["APP_VERSION"] = "v1.0.0"
    proc = subprocess.Popen(["node", APP_PATH], env=env)
    return proc

def start_secondary():
    env = os.environ.copy()
    env["PORT"] = "8082"
    env["REGION"] = "West US 3 (Secondary Warm Standby)"
    env["APP_VERSION"] = "v1.0.0"
    proc = subprocess.Popen(["node", APP_PATH], env=env)
    return proc

if __name__ == "__main__":
    print(f"[*] Starting Primary Region (East US 2) on port 8081...")
    p1 = start_primary()
    print(f"[*] Starting Secondary Region (West US 3) on port 8082...")
    p2 = start_secondary()
    print("[+] Both regional workloads started successfully.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[*] Stopping regional servers...")
        p1.terminate()
        p2.terminate()
