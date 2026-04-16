# Datadog Logs Monitor

Alert on log patterns, counts, and anomalies.

## Features

- **Log Pattern Matching** — Alert on specific log patterns
- **Log Count Thresholds** — Alert when log volume exceeds threshold
- **Anomaly Detection** — Detect unusual log patterns
- **Multi-Alert** — Alert by service, host, or custom tags

## Usage

```hcl
module "logs_monitor" {
  source = "./datadog/monitors/logs"
  config_file = "monitors/error-spike.yaml"
}
```

## Common Queries

**Error Spike:**
```yaml
query: "logs(\"status:error service:api\").index(\"main\").rollup(\"count\").last(\"5m\") > 100"
```

**Critical Logs:**
```yaml
query: "logs(\"status:critical\").index(\"main\").rollup(\"count\").last(\"5m\") > 0"
```
