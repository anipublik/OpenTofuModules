# GCP Monitoring Alert Module

Production-hardened Cloud Monitoring alerts with notification channels.

## Features

- **Metric Alerts** — Threshold-based alerts
- **Notification Channels** — Email, SMS, webhooks
- **Alert Policies** — Condition-based alerting
- **Documentation** — Alert descriptions

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: app-monitoring
  team: platform
  cost_center: eng-001

alerts:
  - name: high-cpu
    condition:
      display_name: High CPU Usage
      filter: |
        metric.type="compute.googleapis.com/instance/cpu/utilization"
        resource.type="gce_instance"
      threshold_value: 0.8
      comparison: COMPARISON_GT
      duration: 300s
      aggregation:
        alignment_period: 60s
        per_series_aligner: ALIGN_MEAN
    notification_channels:
      - projects/my-project/notificationChannels/123456
    documentation: CPU usage exceeded 80%

notification_channels:
  - display_name: Ops Team Email
    type: email
    labels:
      email_address: ops@example.com

gcp:
  project_id: my-project

tags:
  alerting: enabled
```

## Usage

```hcl
module "alert" {
  source = "./gcp/observability/alert"
  config_file = "alert.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | First alert policy ID |
| `alert_policy_ids` | Map of alert policy IDs |
| `notification_channel_ids` | Map of notification channel IDs |
