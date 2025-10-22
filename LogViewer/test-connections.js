const http = require('http');

// Test function to check internal service connections
async function testConnections() {
    console.log('Testing LogViewer internal connections...\n');
    
    // Test health endpoint
    try {
        const healthResponse = await makeRequest('http://localhost:3001/health');
        console.log('✅ LogViewer health check:', healthResponse.status === 200 ? 'PASS' : 'FAIL');
    } catch (error) {
        console.log('❌ LogViewer health check: FAIL -', error.message);
    }
    
    // Test Loki proxy
    try {
        const lokiResponse = await makeRequest('http://localhost:3001/api/loki/ready');
        console.log('✅ Loki proxy connection:', lokiResponse.status === 200 ? 'PASS' : 'FAIL');
    } catch (error) {
        console.log('❌ Loki proxy connection: FAIL -', error.message);
    }
    
    // Test API proxy
    try {
        const apiResponse = await makeRequest('http://localhost:3001/api/test/WeatherForecast');
        console.log('✅ API proxy connection:', apiResponse.status === 200 ? 'PASS' : 'FAIL');
    } catch (error) {
        console.log('❌ API proxy connection: FAIL -', error.message);
    }
    
    console.log('\nTest completed. If any tests failed, check that all services are running.');
}

function makeRequest(url) {
    return new Promise((resolve, reject) => {
        const req = http.get(url, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve({ status: res.statusCode, data }));
        });
        
        req.on('error', reject);
        req.setTimeout(5000, () => {
            req.destroy();
            reject(new Error('Request timeout'));
        });
    });
}

// Run tests if this script is executed directly
if (require.main === module) {
    testConnections();
}

module.exports = { testConnections };
