const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname)));

// Proxy to Loki API
app.use('/api/loki', createProxyMiddleware({
    target: 'http://localhost:3100',
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
    target: 'http://localhost:5000',
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

app.listen(PORT, () => {
    console.log(`Log Viewer server running on http://localhost:${PORT}`);
    console.log(`Proxying Loki API from http://localhost:3100`);
    console.log(`Proxying Test API from http://localhost:5000`);
});
