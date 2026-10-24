const express = require('express');
const os = require('os');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || "1.0.0";
const START_TIME = new Date();

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

// Health Check Endpoint (Used by Jenkins CI/CD post-deployment validation)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    version: VERSION,
    uptimeSeconds: Math.floor(process.uptime()),
    timestamp: new Date().toISOString(),
    hostname: os.hostname()
  });
});

// System Information API
app.get('/api/info', (req, res) => {
  res.status(200).json({
    app: 'Azure DevOps CI/CD Showcase App',
    version: VERSION,
    startTime: START_TIME.toISOString(),
    uptimeSeconds: Math.floor(process.uptime()),
    system: {
      hostname: os.hostname(),
      platform: os.platform(),
      release: os.release(),
      arch: os.arch(),
      cpus: os.cpus().length,
      totalMemoryMB: Math.round(os.totalmem() / 1024 / 1024),
      freeMemoryMB: Math.round(os.freemem() / 1024 / 1024)
    },
    cloud: {
      provider: 'Microsoft Azure',
      environment: process.env.NODE_ENV || 'production',
      provisioner: 'Terraform'
    }
  });
});

// Fallback for root route if index.html is served statically
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start listening if not required by tests
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`=========================================`);
    console.log(`🚀 DevOps App is running!`);
    console.log(`📡 URL: http://0.0.0.0:${PORT}`);
    console.log(`🏥 Health check: http://0.0.0.0:${PORT}/health`);
    console.log(`⏱️  Started at: ${START_TIME.toISOString()}`);
    console.log(`=========================================`);
  });
}

module.exports = app;
