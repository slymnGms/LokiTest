using Serilog;
using Serilog.Events;
using Serilog.Sinks.Loki;
using Serilog.Sinks.Loki.Labels;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
var lokiUrl = builder.Configuration["LOKI_URL"] ?? "http://localhost:3100";

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
    .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "LokiTest")
    .Enrich.WithProperty("Environment", builder.Environment.EnvironmentName)
    .WriteTo.Console()
    .WriteTo.File("logs/lokitest-api-.log", 
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 7)
    .WriteTo.LokiHttp(new NoAuthCredentials(lokiUrl))
    .CreateLogger();

builder.Host.UseSerilog();

// Add services to the container.
builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

try
{
    Log.Information("Starting LokiTest API - Logging directly to Loki at {LokiUrl}", lokiUrl);
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
