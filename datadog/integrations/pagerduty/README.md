# Datadog PagerDuty Integration

Integrate Datadog with PagerDuty for incident management.

## Features

- **Multi-Service Support** — Configure multiple PagerDuty services
- **Automatic Incidents** — Create incidents from alerts
- **Bidirectional Sync** — Sync status between platforms

## Usage

```hcl
module "pagerduty_integration" {
  source = "./datadog/integrations/pagerduty"
  config_file = "integrations/pagerduty.yaml"
}
```
