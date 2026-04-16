# Datadog Monitor SLO

Track Service Level Objectives based on monitor uptime.

## Features

- **Monitor-Based** — Use existing monitors
- **Multiple Monitors** — Aggregate multiple monitors
- **Uptime Calculation** — Automatic uptime tracking
- **Error Budget** — Track remaining error budget

## Usage

```hcl
module "monitor_slo" {
  source = "./datadog/slo/monitor"
  config_file = "slo/service-uptime.yaml"
}
```
