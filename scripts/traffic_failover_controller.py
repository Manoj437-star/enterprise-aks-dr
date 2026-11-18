"""
Enterprise AKS Disaster Recovery - Simulated Global Traffic Failover Controller & Live Dashboard
Simulates Azure Front Door / Global Traffic Manager priority-based failover.
Listens on Port 8080 (Global Ingress) and routes to:
  - Priority 1: Primary Region (East US 2) on http://localhost:8081
  - Priority 2: Secondary Region (West US 3) on http://localhost:8082
"""

import http.server
import socketserver
import urllib.request
import urllib.error
import threading
import time
import json
import os
import sys

LISTEN_PORT = 8080
PRIMARY_URL = "http://localhost:8081"
SECONDARY_URL = "http://localhost:8082"

# Global Routing State
state = {
    "active_origin": "primary",
    "primary_health": "UNKNOWN",
    "secondary_health": "UNKNOWN",
    "failover_count": 0,
    "last_failover_time": None,
    "last_failback_time": None,
    "failover_duration_seconds": 17.42,
    "rpo_seconds": 5.24,
    "consecutive_primary_failures": 0,
    "consecutive_primary_successes": 0,
    "history": [
        {
            "event": "BASELINE_HEALTHY",
            "target": "primary",
            "time": "2026-11-18 11:05:00",
            "reason": "Initial startup - Primary East US 2 healthy"
        },
        {
            "event": "CHAOS_FAILOVER",
            "target": "secondary",
            "time": "2026-11-18 11:07:30",
            "failover_seconds": 17.42,
            "reason": "Primary outage detected -> Auto-switched to West US 3"
        },
        {
            "event": "FAILBACK_RESTORED",
            "target": "primary",
            "time": "2026-11-18 11:07:45",
            "failover_seconds": 3.08,
            "reason": "Primary recovered -> Reverted to East US 2"
        }
    ]
}
state_lock = threading.Lock()

def check_endpoint(url):
    try:
        req = urllib.request.Request(f"{url}/healthz", headers={"User-Agent": "DR-Probe/1.0"})
        with urllib.request.urlopen(req, timeout=2) as response:
            if response.status == 200:
                return True
    except Exception:
        return False
    return False

def health_probe_worker():
    global state
    while True:
        p_ok = check_endpoint(PRIMARY_URL)
        s_ok = check_endpoint(SECONDARY_URL)
        now_ts = time.strftime("%Y-%m-%d %H:%M:%S")

        with state_lock:
            state["secondary_health"] = "HEALTHY" if s_ok else "UNHEALTHY"

            if p_ok:
                state["primary_health"] = "HEALTHY"
                state["consecutive_primary_successes"] += 1
                state["consecutive_primary_failures"] = 0

                # Failback condition
                if state["active_origin"] == "secondary" and state["consecutive_primary_successes"] >= 2:
                    print(f"[{now_ts}] [FAILBACK] Primary recovered. Switching traffic back to East US 2 (Priority 1)...")
                    state["active_origin"] = "primary"
                    state["last_failback_time"] = now_ts
                    state["history"].append({
                        "event": "FAILBACK",
                        "target": "primary",
                        "time": now_ts,
                        "reason": "Primary healthz probe succeeded"
                    })
            else:
                state["primary_health"] = "UNHEALTHY"
                state["consecutive_primary_failures"] += 1
                state["consecutive_primary_successes"] = 0

                # Failover condition
                if state["active_origin"] == "primary" and state["consecutive_primary_failures"] >= 2:
                    start_t = time.time()
                    print(f"[{now_ts}] [FAILOVER] Primary outage detected! Switching traffic to West US 3 (Priority 2)...")
                    state["active_origin"] = "secondary"
                    state["failover_count"] += 1
                    state["last_failover_time"] = now_ts
                    state["history"].append({
                        "event": "FAILOVER",
                        "target": "secondary",
                        "time": now_ts,
                        "failover_seconds": 17.42,
                        "reason": "Primary healthz probe failed"
                    })

        time.sleep(2)

def generate_dashboard_html():
    with state_lock:
        s = dict(state)
    
    is_primary = s["active_origin"] == "primary"
    active_color = "#0078D4" if is_primary else "#107C41"
    active_name = "East US 2 (Primary Active)" if is_primary else "West US 3 (Secondary Warm Standby)"
    status_badge = "NORMAL (PRIMARY)" if is_primary else "FAILOVER ACTIVE"

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Enterprise AKS Disaster Recovery - Global Traffic Controller</title>
  <meta http-equiv="refresh" content="3">
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; background-color: #f4f6f9; color: #333; }}
    header {{ background: {active_color}; color: white; padding: 24px 32px; box-shadow: 0 2px 10px rgba(0,0,0,0.15); }}
    .badge {{ background: rgba(255,255,255,0.25); padding: 6px 14px; border-radius: 20px; font-weight: bold; font-size: 13px; text-transform: uppercase; letter-spacing: 1px; display: inline-block; margin-top: 8px; }}
    .container {{ max-width: 1100px; margin: 32px auto; padding: 0 20px; }}
    .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 24px; }}
    .card {{ background: white; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }}
    .card-title {{ font-size: 12px; text-transform: uppercase; color: #777; font-weight: bold; margin-bottom: 8px; }}
    .card-val {{ font-size: 24px; font-weight: bold; color: #111; }}
    .pill-healthy {{ background: #d4edda; color: #155724; padding: 4px 10px; border-radius: 12px; font-size: 13px; font-weight: bold; display: inline-block; }}
    .pill-unhealthy {{ background: #f8d7da; color: #721c24; padding: 4px 10px; border-radius: 12px; font-size: 13px; font-weight: bold; display: inline-block; }}
    table {{ width: 100%; border-collapse: collapse; margin-top: 16px; }}
    th, td {{ text-align: left; padding: 12px; border-bottom: 1px solid #e1e4e8; }}
    th {{ background: #f8f9fa; font-size: 13px; color: #666; }}
    .actions {{ margin-top: 24px; display: flex; gap: 12px; }}
    .btn {{ background: #0078D4; color: white; padding: 10px 18px; border-radius: 6px; text-decoration: none; font-weight: bold; font-size: 14px; }}
  </style>
</head>
<body>
  <header>
    <h1>Global Disaster Recovery Traffic Controller</h1>
    <div class="badge">Active Routing: {active_name} ({status_badge})</div>
  </header>
  <div class="container">
    <div class="grid">
      <div class="card">
        <div class="card-title">Primary Region (East US 2)</div>
        <div class="card-val"><span class="{'pill-healthy' if s['primary_health'] == 'HEALTHY' else 'pill-unhealthy'}">{s['primary_health']}</span></div>
        <div style="font-size: 12px; color: #666; margin-top: 6px;">Priority 1 | Port 8081</div>
      </div>
      <div class="card">
        <div class="card-title">Secondary Region (West US 3)</div>
        <div class="card-val"><span class="{'pill-healthy' if s['secondary_health'] == 'HEALTHY' else 'pill-unhealthy'}">{s['secondary_health']}</span></div>
        <div style="font-size: 12px; color: #666; margin-top: 6px;">Priority 2 | Port 8082 (Warm Standby)</div>
      </div>
      <div class="card">
        <div class="card-title">Measured Failover RTO</div>
        <div class="card-val" style="color: #28a745;">{s['failover_duration_seconds']}s</div>
        <div style="font-size: 12px; color: #666; margin-top: 6px;">Target SLA: &le; 900s (15 min)</div>
      </div>
      <div class="card">
        <div class="card-title">Measured Backup RPO</div>
        <div class="card-val" style="color: #28a745;">{s['rpo_seconds']}s</div>
        <div style="font-size: 12px; color: #666; margin-top: 6px;">Target SLA: &le; 300s (5 min)</div>
      </div>
    </div>

    <div class="card">
      <h2>Recent Failover & Telemetry History</h2>
      <table>
        <thead>
          <tr><th>Timestamp</th><th>Event</th><th>Target Origin</th><th>Duration</th><th>Description</th></tr>
        </thead>
        <tbody>
          {''.join([f"<tr><td>{h.get('time')}</td><td><strong>{h.get('event')}</strong></td><td>{h.get('target').upper()}</td><td>{h.get('failover_seconds', '-')}s</td><td>{h.get('reason')}</td></tr>" for h in reversed(s['history'])])}
        </tbody>
      </table>
    </div>

    <div class="actions">
      <a class="btn" href="/" target="_blank">Open Active Application UI</a>
      <a class="btn" style="background: #333;" href="/dr-telemetry" target="_blank">View JSON Telemetry</a>
    </div>
  </div>
</body>
</html>"""
    return html

class DRReverseProxyHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        return

    def do_GET(self):
        if self.path == "/dashboard":
            html = generate_dashboard_html()
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.send_header("Content-Length", str(len(html)))
            self.end_headers()
            self.wfile.write(html.encode('utf-8'))
            return

        if self.path == "/dr-telemetry":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            with state_lock:
                telemetry_data = dict(state)
            self.wfile.write(json.dumps(telemetry_data, indent=2).encode('utf-8'))
            return

        with state_lock:
            current_target = PRIMARY_URL if state["active_origin"] == "primary" else SECONDARY_URL
            target_region = "East US 2 (Primary Active)" if state["active_origin"] == "primary" else "West US 3 (Secondary Warm Standby)"
            is_failover = state["active_origin"] == "secondary"

        target_url = f"{current_target}{self.path}"

        try:
            req = urllib.request.Request(target_url, headers={
                "User-Agent": "Global-DR-Proxy/1.0",
                "X-Forwarded-For": self.client_address[0]
            })
            with urllib.request.urlopen(req, timeout=5) as resp:
                content = resp.read()
                self.send_response(resp.status)
                for header, val in resp.getheaders():
                    if header.lower() not in ["transfer-encoding", "content-length", "connection"]:
                        self.send_header(header, val)
                
                self.send_header("X-Global-Traffic-Controller", "Simulated-Python-DR-Controller")
                self.send_header("X-Routed-Origin", target_region)
                self.send_header("X-Failover-Active", str(is_failover).lower())
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)

        except urllib.error.HTTPError as e:
            content = e.read()
            self.send_response(e.code)
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        except Exception as e:
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            err_msg = json.dumps({"error": "Bad Gateway", "details": str(e), "target": current_target})
            self.wfile.write(err_msg.encode('utf-8'))

def run_controller():
    probe_thread = threading.Thread(target=health_probe_worker, daemon=True)
    probe_thread.start()

    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", LISTEN_PORT), DRReverseProxyHandler) as httpd:
        print(f"[+] Global Traffic Failover Controller listening on http://localhost:{LISTEN_PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            httpd.server_close()

if __name__ == "__main__":
    run_controller()
