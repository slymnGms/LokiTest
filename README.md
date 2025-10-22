# Loki Log Monitoring System

A complete logging solution using Grafana Loki, integrated with a .NET API and a web-based log viewer with filtering and pagination capabilities.

## Architecture

- **Loki**: Log aggregation system
- **Grafana**: Log visualization and dashboards
- **Promtail**: Log collection agent
- **.NET API**: Sample application with structured logging
- **Web Log Viewer**: Custom web interface for log viewing with filtering and pagination

## Services

| Service | Port | Description |
|---------|------|-------------|
| Loki | 3100 | Log aggregation system |
| Grafana | 3000 | Log visualization (admin/admin) |
| API | 5000 | .NET Web API with logging |
| Log Viewer | 3001 | Custom web interface |
| Promtail | - | Log collection agent |

## Quick Start

### Prerequisites

- Docker and Docker Compose
- .NET 9.0 SDK (for local development)

### Running with Docker Compose

1. **Start all services:**
   ```bash
   docker-compose up -d
   ```

2. **Access the services:**
   - **Log Viewer**: http://localhost:3001
   - **Grafana**: http://localhost:3000 (admin/admin)
   - **API**: http://localhost:5000
   - **Loki API**: http://localhost:3100

3. **Generate test logs:**
   - Visit the Log Viewer at http://localhost:3001
   - Click "Generate Test Logs" button
   - View logs with filtering and pagination

### API Endpoints

The API provides several endpoints for testing logging:

- `GET /WeatherForecast` - Get weather forecast (with logging)
- `POST /WeatherForecast/test-logs` - Generate test logs
- `GET /WeatherForecast/error-test` - Generate error logs
- `POST /WeatherForecast/performance-test` - Generate performance logs

### Log Viewer Features

- **Real-time log viewing** with auto-refresh
- **Advanced filtering** by log level, message content, and time range
- **Pagination** with configurable page sizes
- **Structured log parsing** from Serilog JSON format
- **Responsive design** for mobile and desktop

### Log Levels

The system supports all standard log levels:
- **Trace**: Detailed debugging information
- **Debug**: Debug information
- **Info**: General information
- **Warn**: Warning messages
- **Error**: Error conditions
- **Critical**: Critical errors

## Configuration

### Loki Configuration

The Loki configuration is in `loki-config.yaml`:
- File-based storage for development
- 24-hour retention period
- In-memory ring store

### Promtail Configuration

Promtail is configured in `promtail-config.yaml` to:
- Collect logs from the API container
- Parse JSON log format
- Send logs to Loki

### API Logging

The .NET API uses Serilog with:
- Console output
- File logging (daily rotation)
- Loki HTTP sink
- Structured logging with context

## Development

### Running Locally

1. **Start Loki and Grafana:**
   ```bash
   docker-compose up loki grafana promtail -d
   ```

2. **Run the API:**
   ```bash
   cd LokiTest
   dotnet run
   ```

3. **Run the Log Viewer:**
   ```bash
   cd LogViewer
   npm install
   npm start
   ```

### Adding New Log Sources

To add new log sources:

1. Update `promtail-config.yaml` with new scrape configs
2. Restart Promtail: `docker-compose restart promtail`

### Customizing Log Parsing

The web viewer parses Serilog JSON format. To customize:

1. Update the `parseLokiResponse` function in `LogViewer/index.html`
2. Modify the log display format as needed

## Monitoring

### Grafana Dashboards

Access Grafana at http://localhost:3000 to:
- View log streams
- Create custom dashboards
- Set up alerts
- Explore log data

### Health Checks

- **API**: http://localhost:5000/health
- **Log Viewer**: http://localhost:3001/health
- **Loki**: http://localhost:3100/ready

## Troubleshooting

### Common Issues

1. **Logs not appearing:**
   - Check if Loki is running: `docker-compose ps`
   - Verify Promtail is collecting logs: `docker-compose logs promtail`
   - Check API logs: `docker-compose logs lokitest-api`

2. **Web viewer not loading:**
   - Ensure all services are running
   - Check browser console for errors
   - Verify API connectivity

3. **Performance issues:**
   - Adjust log retention in `loki-config.yaml`
   - Increase Promtail scrape intervals
   - Optimize log queries

### Logs Location

- **API logs**: `LokiTest/logs/` directory
- **Container logs**: Docker logs via `docker-compose logs`
- **Loki storage**: Docker volume `loki-storage`

## Production Considerations

For production deployment:

1. **Security:**
   - Enable authentication in Loki
   - Use HTTPS for all services
   - Secure API endpoints

2. **Storage:**
   - Use persistent volumes for Loki
   - Configure log retention policies
   - Set up log rotation

3. **Monitoring:**
   - Add health checks
   - Set up alerts
   - Monitor resource usage

4. **Scaling:**
   - Use external storage for Loki
   - Scale Promtail instances
   - Load balance the API

## License

MIT License - see LICENSE file for details.
