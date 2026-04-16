# Datadog APM Monitor

Monitor application performance metrics including latency, error rate, and throughput.

## Features

- **Trace Metrics** — Monitor request duration, error rate, hits per second
- **Multi-Alert** — Alert by service, resource, environment, or custom tags
- **Threshold Alerting** — Critical and warning thresholds with recovery values
- **Notification Routing** — Route alerts to Slack, PagerDuty, email
- **Evaluation Delay** — Prevent false positives from delayed metrics
- **No Data Alerts** — Alert when metrics stop reporting

## YAML Configuration

```yaml
meta:
  environment: production
  name: api-latency
  team: backend
  cost_center: eng-001

monitor:
  type: metric alert
  query: "avg(last_5m):avg:trace.http.request.duration{service:api,env:production} > 1"
  message: |
    {{#is_alert}}
    API latency is above 1 second
    Current value: {{value}}
    {{/is_alert}}
    
    {{#is_warning}}
    API latency is elevated: {{value}}
    {{/is_warning}}
    
    @slack-backend-alerts @pagerduty-backend
  
  thresholds:
    critical: 1.0
    warning: 0.5
    critical_recovery: 0.8
    warning_recovery: 0.4
  
  evaluation_delay: 60
  notify_no_data: true
  no_data_timeframe: 10
  renotify_interval: 30
  include_tags: true

tags:
  - service:api
  - severity:high
  - monitor_type:apm
```

## Usage

```hcl
module "apm_monitor" {
  source = "./datadog/monitors/apm"
  config_file = "monitors/api-latency.yaml"
}

output "monitor_id" {
  value = module.apm_monitor.monitor_id
}
```

## Common APM Metrics

**Request Duration:**
```yaml
query: "avg(last_5m):avg:trace.http.request.duration{service:api} > 1"
```

**Error Rate:**
```yaml
query: "avg(last_5m):sum:trace.http.request.errors{service:api}.as_count() / sum:trace.http.request.hits{service:api}.as_count() > 0.05"
```

**Throughput:**
```yaml
query: "avg(last_5m):sum:trace.http.request.hits{service:api}.as_rate() < 100"
```

**Apdex Score:**
```yaml
query: "avg(last_5m):trace.http.request.apdex{service:api} < 0.9"
```

## Multi-Alert by Service

```yaml
query: "avg(last_5m):avg:trace.http.request.duration{env:production} by {service} > 1"
```

This creates separate alerts for each service.

## Notification Templates

Use template variables in messages:

- `{{value}}` — Current metric value
- `{{threshold}}` — Alert threshold
- `{{comparator}}` — Comparison operator
- `{{last_triggered_at}}` — Last trigger time

## Best Practices

- **Evaluation Delay** — Set to 60-120s for APM metrics to account for ingestion delay
- **Recovery Thresholds** — Prevent flapping by setting recovery below alert threshold
- **Multi-Alert** — Use `by {service}` or `by {resource}` for granular alerting
- **No Data Alerts** — Enable for critical services to detect agent failures

## Additional Resources

- [APM Metrics](https://docs.datadoghq.com/tracing/metrics/)
- [Monitor Types](https://docs.datadoghq.com/monitors/types/)
