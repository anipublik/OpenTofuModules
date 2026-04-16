# Azure Monitor Alert Module

Production-hardened Azure Monitor alerts with action groups.

## Features

- **Metric Alerts** — Threshold-based alerts
- **Activity Log Alerts** — Resource activity alerts
- **Action Groups** — Multi-channel notifications
- **Auto-mitigation** — Automatic resolution

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-alerts
  team: platform
  cost_center: eng-001

alert:
  email_receivers:
    - name: ops-team
      email_address: ops@example.com
      use_common_alert_schema: true
  
  webhook_receivers:
    - name: slack
      service_uri: https://hooks.slack.com/services/...
  
  metric_alerts:
    - name: high-cpu
      scopes:
        - /subscriptions/.../providers/Microsoft.Compute/virtualMachineScaleSets/vmss
      severity: 2
      metric_namespace: Microsoft.Compute/virtualMachineScaleSets
      metric_name: Percentage CPU
      aggregation: Average
      operator: GreaterThan
      threshold: 80
      frequency: PT1M
      window_size: PT5M
  
  activity_log_alerts:
    - name: vm-deleted
      scopes:
        - /subscriptions/...
      category: Administrative
      operation_name: Microsoft.Compute/virtualMachines/delete

azure:
  resource_group: production-rg

tags:
  alerting: enabled
```

## Usage

```hcl
module "monitor_alert" {
  source = "./azure/observability/monitor-alert"
  config_file = "monitor-alert.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Action group ID |
| `metric_alert_ids` | Map of metric alert IDs |
