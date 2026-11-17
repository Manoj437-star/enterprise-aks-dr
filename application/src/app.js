const express = require('express');
const os = require('os');
const app = express();

const PORT = process.env.PORT || 8080;
const REGION = process.env.REGION || 'East US 2 (Primary)';
const APP_VERSION = process.env.APP_VERSION || 'v1.0.0';
const startTime = new Date();

// Sample E-Commerce Product Catalog
const products = [
  { id: 1, name: 'Enterprise Cloud Laptop', price: 1299.99, stock: 45 },
  { id: 2, name: 'Kubernetes Admin Mechanical Keyboard', price: 149.50, stock: 120 },
  { id: 3, name: 'Multi-Region High-Res Monitor 4K', price: 499.00, stock: 18 },
  { id: 4, name: 'Noise-Cancelling DevOps Headset', price: 199.99, stock: 65 }
];

// Health Probes for AKS and Front Door
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'HEALTHY', region: REGION, timestamp: new Date().toISOString() });
});

app.get('/readyz', (req, res) => {
  res.status(200).json({ status: 'READY', region: REGION });
});

app.get('/livez', (req, res) => {
  res.status(200).json({ status: 'ALIVE', region: REGION });
});

app.get('/version', (req, res) => {
  res.status(200).json({
    version: APP_VERSION,
    region: REGION,
    hostname: os.hostname(),
    uptimeSeconds: Math.floor((new Date() - startTime) / 1000)
  });
});

app.get('/api/products', (req, res) => {
  res.status(200).json({
    region: REGION,
    total: products.length,
    data: products
  });
});

// Homepage UI
app.get('/', (req, res) => {
  const isPrimary = REGION.toLowerCase().includes('east');
  const bannerColor = isPrimary ? '#0078D4' : '#107C41';
  const regionBadge = isPrimary ? 'PRIMARY ACTIVE' : 'SECONDARY WARM STANDBY';

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Enterprise AKS Disaster Recovery Portal</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; background-color: #f4f6f9; color: #333; }
    header { background: ${bannerColor}; color: white; padding: 24px 32px; box-shadow: 0 2px 10px rgba(0,0,0,0.15); }
    .badge { background: rgba(255,255,255,0.25); padding: 6px 14px; border-radius: 20px; font-weight: bold; font-size: 13px; text-transform: uppercase; letter-spacing: 1px; display: inline-block; margin-top: 8px; }
    .container { max-width: 1000px; margin: 32px auto; padding: 0 20px; }
    .card { background: white; border-radius: 8px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    table { width: 100%; border-collapse: collapse; margin-top: 16px; }
    th, td { text-align: left; padding: 12px; border-bottom: 1px solid #e1e4e8; }
    th { background: #f8f9fa; font-size: 13px; color: #666; }
    .status-dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; background: #28a745; margin-right: 6px; }
    .meta-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-top: 16px; }
    .meta-item { background: #f8f9fa; padding: 12px; border-radius: 6px; }
    .meta-label { font-size: 11px; text-transform: uppercase; color: #777; font-weight: bold; }
    .meta-val { font-size: 16px; font-weight: 600; margin-top: 4px; color: #111; word-break: break-all; }
  </style>
</head>
<body>
  <header>
    <h1>🛒 CloudStore Global E-Commerce</h1>
    <div class="badge">Serving from: ${REGION} (${regionBadge})</div>
  </header>
  <div class="container">
    <div class="card">
      <h2><span class="status-dot"></span> System Telemetry & Cluster Identity</h2>
      <div class="meta-grid">
        <div class="meta-item"><div class="meta-label">Active Region</div><div class="meta-val">${REGION}</div></div>
        <div class="meta-item"><div class="meta-label">Pod Hostname</div><div class="meta-val">${os.hostname()}</div></div>
        <div class="meta-item"><div class="meta-label">App Version</div><div class="meta-val">${APP_VERSION}</div></div>
        <div class="meta-item"><div class="meta-label">Platform OS</div><div class="meta-val">${os.type()} ${os.arch()}</div></div>
      </div>
    </div>

    <div class="card">
      <h2>📦 Product Catalog (Sample Workload)</h2>
      <table>
        <thead>
          <tr><th>ID</th><th>Product Name</th><th>Price</th><th>Stock Status</th></tr>
        </thead>
        <tbody>
          ${products.map(p => `<tr><td>#${p.id}</td><td><strong>${p.name}</strong></td><td>$${p.price.toFixed(2)}</td><td><span class="status-dot"></span>In Stock (${p.stock} units)</td></tr>`).join('')}
        </tbody>
      </table>
    </div>
  </div>
</body>
</html>`;
  res.send(html);
});

app.listen(PORT, () => {
  console.log(`CloudStore E-Commerce server running on port ${PORT} [Region: ${REGION}]`);
});
