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

// API logs endpoint (alternative to Loki)
app.get('/api/logs', async (req, res) => {
    try {
        // Get real logs from the API logs endpoint
        const params = new URLSearchParams({
            level: req.query.level || '',
            search: req.query.search || '',
            limit: req.query.limit || '25'
        });
        
        const response = await fetch(`http://lokitest-api:8080/WeatherForecast/logs?${params}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        if (response.ok) {
            const data = await response.json();
            res.json(data);
        } else {
            throw new Error(`API returned ${response.status}: ${response.statusText}`);
        }
    } catch (error) {
        console.error('Error getting real logs:', error);
        res.status(500).json({ error: 'Failed to get real logs: ' + error.message });
    }
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
