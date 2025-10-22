# Test script for Loki logging system - PowerShell version
Write-Host "🔍 Testing Loki Logging System..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Test 1: Check if API is running
Write-Host "`n1. Testing API health..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/WeatherForecast" -Method GET
    Write-Host "✅ API is running and responding" -ForegroundColor Green
    Write-Host "   Generated $($response.Count) weather forecasts" -ForegroundColor Cyan
} catch {
    Write-Host "❌ API is not running or not accessible" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Start the API with: docker-compose up lokitest-api" -ForegroundColor Yellow
    exit 1
}

# Test 2: Generate test logs via API
Write-Host "`n2. Generating test logs via API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/WeatherForecast/test-logs" -Method POST
    Write-Host "✅ Test logs generated successfully via API" -ForegroundColor Green
    Write-Host "   Count: $($response.count)" -ForegroundColor Cyan
    Write-Host "   RequestId: $($response.requestId)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Failed to generate test logs via API" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test error logging
Write-Host "`n3. Testing error logging..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/WeatherForecast/error-test" -Method GET
    Write-Host "❌ Error test should have failed but didn't" -ForegroundColor Red
} catch {
    Write-Host "✅ Error test failed as expected (this is good for logging)" -ForegroundColor Green
    Write-Host "   Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Cyan
}

# Test 4: Test performance logging
Write-Host "`n4. Testing performance logging..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/WeatherForecast/performance-test" -Method POST
    Write-Host "✅ Performance test completed" -ForegroundColor Green
    Write-Host "   Elapsed: $($response.elapsedMs)ms" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Performance test failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Check Loki connectivity
Write-Host "`n5. Testing Loki connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3100/ready" -Method GET
    Write-Host "✅ Loki is running and ready" -ForegroundColor Green
} catch {
    Write-Host "❌ Loki is not accessible" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Start Loki with: docker-compose up loki" -ForegroundColor Yellow
}

# Test 6: Check LogViewer
Write-Host "`n6. Testing LogViewer..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method GET
    Write-Host "✅ LogViewer is running" -ForegroundColor Green
    Write-Host "   Status: $($response.status)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ LogViewer is not accessible" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Start LogViewer with: docker-compose up log-viewer" -ForegroundColor Yellow
}

# Test 7: Test direct Loki push (using existing script)
Write-Host "`n7. Testing direct Loki push..." -ForegroundColor Yellow
try {
    & .\send-test-logs.ps1
    Write-Host "✅ Direct Loki push completed" -ForegroundColor Green
} catch {
    Write-Host "❌ Direct Loki push failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Query logs from Loki
Write-Host "`n8. Testing Loki log query..." -ForegroundColor Yellow
try {
    $query = [System.Web.HttpUtility]::UrlEncode('{job="lokitest-api"}')
    $lokiQueryUrl = "http://localhost:3100/loki/api/v1/query_range?query=$query&limit=10&start=$(Get-Date (Get-Date).AddHours(-1) -UFormat %s)000000000&end=$(Get-Date -UFormat %s)000000000"
    
    $response = Invoke-RestMethod -Uri $lokiQueryUrl -Method GET
    if ($response.data.result.Count -gt 0) {
        Write-Host "✅ Successfully queried logs from Loki" -ForegroundColor Green
        Write-Host "   Found $($response.data.result.Count) log streams" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  Loki query succeeded but no logs found" -ForegroundColor Yellow
        Write-Host "   This might be normal if logs are still being processed" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Failed to query logs from Loki" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Testing completed!" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green

Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Open http://localhost:3001 to view logs in the LogViewer" -ForegroundColor White
Write-Host "2. Open http://localhost:3000 to view logs in Grafana (admin/admin)" -ForegroundColor White
Write-Host "3. Check the API console output for real-time logs" -ForegroundColor White
Write-Host "4. Run 'docker-compose logs lokitest-api' to see container logs" -ForegroundColor White

Write-Host "`n🚀 Quick start commands:" -ForegroundColor Cyan
Write-Host "Start all services: docker-compose up -d" -ForegroundColor White
Write-Host "View logs: docker-compose logs -f lokitest-api" -ForegroundColor White
Write-Host "Stop services: docker-compose down" -ForegroundColor White
