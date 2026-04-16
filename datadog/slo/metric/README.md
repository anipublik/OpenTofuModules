# Datadog Metric SLO

Track Service Level Objectives based on custom metrics.

## Features

- **Custom Queries** — Define numerator and denominator
- **Multiple Timeframes** — 7d, 30d, 90d tracking
- **Error Budget** — Track remaining error budget
- **Burn Rate Alerts** — Alert on rapid budget consumption

## Usage

```hcl
module "metric_slo" {
  source = "./datadog/slo/metric"
  config_file = "slo/api-availability.yaml"
}
```
