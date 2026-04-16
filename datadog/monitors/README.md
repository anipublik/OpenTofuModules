# Datadog Monitors

Alert on metrics, traces, logs, and custom conditions with notification routing.

## Modules

### [APM Monitor](./apm/README.md)
Application performance monitoring with:
- Trace metrics (latency, error rate, throughput)
- Service and resource-level alerting
- Multi-alert by service, environment, or resource

### [Infrastructure Monitor](./infrastructure/README.md)
Host and container monitoring with:
- CPU, memory, disk, network metrics
- Process and container alerts
- Multi-alert by host or container

### [Logs Monitor](./logs/README.md)
Log-based alerting with:
- Log pattern matching
- Log count thresholds
- Anomaly detection on log volume

### [Custom Monitor](./custom/README.md)
Custom metric monitoring with:
- Metric queries with aggregation
- Threshold and anomaly detection
- Forecast-based alerting

### [Composite Monitor](./composite/README.md)
Multi-condition alerts with:
- Boolean logic (AND, OR)
- Cross-metric correlation
- Reduced alert fatigue
