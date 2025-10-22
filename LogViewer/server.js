const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Get service URLs from environment variables or use defaults
const LOKI_URL = process.env.LOKI_URL || 'http://localhost:3100';
const API_URL = process.env.API_URL || 'http://localhost:5000';

console.log(`Starting LogViewer server on port ${PORT}`);
console.log(`Loki URL: ${LOKI_URL}`);
console.log(`API URL: ${API_URL}`);

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname)));

// Proxy to Loki API
app.use('/api/loki', createProxyMiddleware({
    target: LOKI_URL,
    changeOrigin: true,
    pathRewrite: {
        '^/api/loki': ''
    },
    onError: (err, req, res) => {
        console.error('Loki proxy error:', err);
        res.status(500).json({ error: 'Failed to connect to Loki' });
    }
}));

// Proxy to API for test log generation
app.use('/api/test', createProxyMiddleware({
    target: API_URL,
    changeOrigin: true,
    pathRewrite: {
        '^/api/test': ''
    },
    onError: (err, req, res) => {
        console.error('API proxy error:', err);
        res.status(500).json({ error: 'Failed to connect to API' });
    }
}));

// Serve the main page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Log Viewer server running on http://0.0.0.0:${PORT}`);
    console.log(`Proxying Loki API from ${LOKI_URL}`);
    console.log(`Proxying Test API from ${API_URL}`);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
    process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
    process.exit(1);
});
