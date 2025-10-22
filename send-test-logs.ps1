# Send test logs to Loki
$lokiUrl = "http://localhost:3100/loki/api/v1/push"
$timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() * 1000000

$logs = @(
    @{
        stream = @{ job = "lokitest-api"; level = "info"; source = "WeatherForecastController" }
        values = @(, @($timestamp.ToString(), "Weather forecast requested"))
    },
    @{
        stream = @{ job = "lokitest-api"; level = "info"; source = "WeatherForecastController" }
        values = @(, @(($timestamp + 1000000).ToString(), "Generated 5 weather forecasts"))
    },
    @{
        stream = @{ job = "lokitest-api"; level = "error"; source = "WeatherForecastController" }
        values = @(, @(($timestamp + 2000000).ToString(), "Error processing item 3: Simulated error"))
    },
    @{
        stream = @{ job = "lokitest-api"; level = "warn"; source = "DatabaseService" }
        values = @(, @(($timestamp + 3000000).ToString(), "Database connection timeout"))
    },
    @{
        stream = @{ job = "lokitest-api"; level = "debug"; source = "CacheService" }
        values = @(, @(($timestamp + 4000000).ToString(), "Cache miss for key: user:123"))
    }
)

$payload = @{
    streams = $logs
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri $lokiUrl -Method Post -Body $payload -ContentType "application/json"
    Write-Host "Successfully sent test logs to Loki"
    Write-Host "Response: $response"
} catch {
    Write-Host "Error sending logs to Loki: $($_.Exception.Message)"
}
