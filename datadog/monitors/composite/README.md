# Datadog Composite Monitor

Combine multiple monitors with boolean logic to reduce alert fatigue.

## Features

- **Boolean Logic** — AND, OR combinations
- **Cross-Metric Correlation** — Alert on multiple conditions
- **Reduced Noise** — Fewer false positives
- **Simplified Alerting** — Single alert for complex conditions

## Usage

```hcl
module "composite_monitor" {
  source = "./datadog/monitors/composite"
  config_file = "monitors/service-degraded.yaml"
}
```

## Query Format

```yaml
query: "12345 && 67890"  # Both monitors must be alerting
query: "12345 || 67890"  # Either monitor alerting
query: "12345 && (67890 || 11111)"  # Complex logic
```
