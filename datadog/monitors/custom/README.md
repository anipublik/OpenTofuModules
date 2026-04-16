# Datadog Custom Monitor

Monitor custom metrics with flexible queries and thresholds.

## Features

- **Custom Metrics** — Monitor any custom metric
- **Flexible Queries** — Complex aggregations and functions
- **Anomaly Detection** — Detect unusual metric behavior
- **Forecast Alerts** — Alert on predicted threshold breaches

## Usage

```hcl
module "custom_monitor" {
  source = "./datadog/monitors/custom"
  config_file = "monitors/queue-depth.yaml"
}
```

## Monitor Types

- `metric alert` — Threshold-based alerting
- `query alert` — Complex query-based alerting
- `anomaly` — Anomaly detection
- `forecast` — Predictive alerting
