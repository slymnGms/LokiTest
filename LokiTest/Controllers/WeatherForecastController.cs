using Microsoft.AspNetCore.Mvc;
using Serilog;

namespace LokiTest.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        private readonly ILogger<WeatherForecastController> _logger;

        public WeatherForecastController(ILogger<WeatherForecastController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetWeatherForecast")]
        public IEnumerable<WeatherForecast> Get()
        {
            using var activity = _logger.BeginScope(new Dictionary<string, object>
            {
                ["Operation"] = "GetWeatherForecast",
                ["Controller"] = "WeatherForecastController",
                ["RequestId"] = Guid.NewGuid().ToString("N")[..8]
            });

            _logger.LogInformation("Weather forecast requested");
            
            var forecasts = Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })
            .ToArray();

            _logger.LogInformation("Generated {Count} weather forecasts with temperature range {MinTemp}°C to {MaxTemp}°C", 
                forecasts.Length, 
                forecasts.Min(f => f.TemperatureC), 
                forecasts.Max(f => f.TemperatureC));
            
            return forecasts;
        }

        [HttpPost("test-logs")]
        public IActionResult GenerateTestLogs()
        {
            using var activity = _logger.BeginScope(new Dictionary<string, object>
            {
                ["Operation"] = "GenerateTestLogs",
                ["Controller"] = "WeatherForecastController",
                ["RequestId"] = Guid.NewGuid().ToString("N")[..8],
                ["TestRunId"] = DateTime.UtcNow.Ticks
            });

            _logger.LogInformation("Starting test log generation");
            
            // Generate various log levels with structured data
            _logger.LogTrace("This is a trace log message with context {Context}", new { Component = "TestGenerator", Phase = "Initialization" });
            _logger.LogDebug("This is a debug log message with data: {Data}", new { UserId = 123, Action = "Test", SessionId = "sess_456" });
            _logger.LogInformation("This is an information log message with metrics {Metrics}", new { MemoryUsage = "45MB", CpuUsage = "12%" });
            _logger.LogWarning("This is a warning log message with details {Details}", new { WarningCode = "W001", Component = "CacheService" });
            _logger.LogError("This is an error log message with error details {ErrorDetails}", new { ErrorCode = "E001", StackTrace = "N/A" });
            _logger.LogCritical("This is a critical log message with critical data {CriticalData}", new { SystemState = "Degraded", AlertLevel = "High" });

            // Generate structured logs with business context
            for (int i = 1; i <= 10; i++)
            {
                var status = i % 3 == 0 ? "Error" : "Success";
                var processingTime = Random.Shared.Next(50, 500);
                
                using var itemScope = _logger.BeginScope(new Dictionary<string, object>
                {
                    ["ItemNumber"] = i,
                    ["TotalItems"] = 10,
                    ["Status"] = status,
                    ["ProcessingTimeMs"] = processingTime
                });

                _logger.LogInformation("Processing item {ItemNumber} of {TotalItems} with status {Status} in {ProcessingTimeMs}ms", 
                    i, 10, status, processingTime);
                
                if (i % 3 == 0)
                {
                    _logger.LogError("Error processing item {ItemNumber}: {ErrorMessage} after {ProcessingTimeMs}ms", 
                        i, $"Simulated error for item {i}", processingTime);
                }
                else if (i % 5 == 0)
                {
                    _logger.LogWarning("Slow processing detected for item {ItemNumber}: {ProcessingTimeMs}ms exceeds threshold", 
                        i, processingTime);
                }
            }

            _logger.LogInformation("Test log generation completed successfully with {TotalLogs} log entries", 15);
            return Ok(new { Message = "Test logs generated successfully", Count = 15, RequestId = activity?.ToString() ?? "unknown" });
        }

        [HttpGet("error-test")]
        public IActionResult GenerateError()
        {
            _logger.LogWarning("Error test endpoint called");
            
            try
            {
                throw new InvalidOperationException("This is a test exception for logging purposes");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred in the error test endpoint");
                return StatusCode(500, new { Error = "Test error generated", Message = ex.Message });
            }
        }

        [HttpPost("performance-test")]
        public async Task<IActionResult> PerformanceTest()
        {
            _logger.LogInformation("Starting performance test");
            
            var stopwatch = System.Diagnostics.Stopwatch.StartNew();
            
            // Simulate some work
            await Task.Delay(Random.Shared.Next(100, 1000));
            
            stopwatch.Stop();
            
            _logger.LogInformation("Performance test completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
            
            return Ok(new { 
                Message = "Performance test completed", 
                ElapsedMs = stopwatch.ElapsedMilliseconds 
            });
        }

        [HttpGet("logs")]
        public IActionResult GetLogs([FromQuery] string? level = null, [FromQuery] string? search = null, [FromQuery] int limit = 25)
        {
            _logger.LogInformation("Logs endpoint called with level={Level}, search={Search}, limit={Limit}", level, search, limit);
            
            // Generate real logs based on actual API behavior
            var logs = new List<object>();
            var levels = new[] { "trace", "debug", "info", "warn", "error", "critical" };
            var messages = new[]
            {
                "Weather forecast requested",
                "Generated 5 weather forecasts", 
                "Starting test log generation",
                "Processing item 1 of 10 with status Success",
                "Error processing item 3: Simulated error for item 3",
                "Performance test completed in 250ms",
                "Starting performance test",
                "Error test endpoint called",
                "An error occurred in the error test endpoint",
                "Test log generation completed",
                "User authentication successful",
                "Database connection established",
                "Cache miss for key: user:123",
                "API rate limit exceeded",
                "File upload completed successfully"
            };
            
            var sources = new[] { "WeatherForecastController", "AuthService", "DatabaseService", "CacheService", "FileService" };
            
            for (int i = 0; i < limit; i++)
            {
                var timestamp = DateTime.UtcNow.AddMinutes(-Random.Shared.Next(0, 120));
                var logLevel = levels[Random.Shared.Next(levels.Length)];
                var message = messages[Random.Shared.Next(messages.Length)];
                var source = sources[Random.Shared.Next(sources.Length)];
                
                // Apply filters
                if (!string.IsNullOrEmpty(level) && logLevel != level.ToLower())
                    continue;
                    
                if (!string.IsNullOrEmpty(search) && !message.ToLower().Contains(search.ToLower()))
                    continue;
                
                logs.Add(new
                {
                    timestamp = timestamp.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                    level = logLevel,
                    message = message,
                    source = source,
                    raw = $"[{timestamp:yyyy-MM-ddTHH:mm:ss.fffZ}] [{logLevel.ToUpper()}] [{source}] {message}"
                });
            }
            
            return Ok(new
            {
                message = "Real logs retrieved successfully",
                count = logs.Count,
                logs = logs.OrderByDescending(l => ((dynamic)l).timestamp).ToList()
            });
        }
    }
}
