# Quick test commands for Loki system - PowerShell
# Run these commands individually or as a script

Write-Host "🔧 Quick Test Commands for Loki System" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# 1. Start all services
Write-Host "`n1. Start all services:" -ForegroundColor Yellow
Write-Host "docker-compose up -d" -ForegroundColor White

# 2. Check service status
Write-Host "`n2. Check service status:" -ForegroundColor Yellow
Write-Host "docker-compose ps" -ForegroundColor White

# 3. Test API health
Write-Host "`n3. Test API health:" -ForegroundColor Yellow
Write-Host "Invoke-RestMethod -Uri 'http://localhost:5000/WeatherForecast' -Method GET" -ForegroundColor White

# 4. Generate test logs
Write-Host "`n4. Generate test logs:" -ForegroundColor Yellow
Write-Host "Invoke-RestMethod -Uri 'http://localhost:5000/WeatherForecast/test-logs' -Method POST" -ForegroundColor White

# 5. Test error logging
Write-Host "`n5. Test error logging:" -ForegroundColor Yellow
Write-Host "try { Invoke-RestMethod -Uri 'http://localhost:5000/WeatherForecast/error-test' -Method GET } catch { Write-Host 'Error as expected: ' $_.Exception.Message }" -ForegroundColor White

# 6. Test performance logging
Write-Host "`n6. Test performance logging:" -ForegroundColor Yellow
Write-Host "Invoke-RestMethod -Uri 'http://localhost:5000/WeatherForecast/performance-test' -Method POST" -ForegroundColor White

# 7. Check Loki health
Write-Host "`n7. Check Loki health:" -ForegroundColor Yellow
Write-Host "Invoke-RestMethod -Uri 'http://localhost:3100/ready' -Method GET" -ForegroundColor White

# 8. Check LogViewer health
Write-Host "`n8. Check LogViewer health:" -ForegroundColor Yellow
Write-Host "Invoke-RestMethod -Uri 'http://localhost:3001/health' -Method GET" -ForegroundColor White

# 9. Send direct logs to Loki
Write-Host "`n9. Send direct logs to Loki:" -ForegroundColor Yellow
Write-Host ".\send-test-logs.ps1" -ForegroundColor White

# 10. View API logs
Write-Host "`n10. View API logs:" -ForegroundColor Yellow
Write-Host "docker-compose logs -f lokitest-api" -ForegroundColor White

# 11. View all logs
Write-Host "`n11. View all logs:" -ForegroundColor Yellow
Write-Host "docker-compose logs -f" -ForegroundColor White

# 12. Stop services
Write-Host "`n12. Stop services:" -ForegroundColor Yellow
Write-Host "docker-compose down" -ForegroundColor White

Write-Host "`n🌐 Web interfaces:" -ForegroundColor Cyan
Write-Host "LogViewer: http://localhost:3001" -ForegroundColor White
Write-Host "Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host "API Swagger: http://localhost:5000/swagger" -ForegroundColor White

Write-Host "`n📝 Run the full test suite:" -ForegroundColor Cyan
Write-Host ".\test-loki-system.ps1" -ForegroundColor White
