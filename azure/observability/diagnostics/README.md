# Azure Diagnostics Module

Production-hardened Diagnostic Settings for Azure resources.

## Features

- **Log Categories** — Selective log collection
- **Metrics** — Performance metrics
- **Multiple Destinations** — Log Analytics, Storage, Event Hub
- **Retention** — Configurable retention

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-diagnostics
  team: platform
  cost_center: eng-001

diagnostics:
  target_resource_id: /subscriptions/.../providers/Microsoft.Web/sites/app
  log_analytics_workspace_id: /subscriptions/.../workspaces/logs
  
  log_categories:
    - AppServiceHTTPLogs
    - AppServiceConsoleLogs
    - AppServiceAppLogs
  
  metric_categories:
    - AllMetrics
  
  retention_enabled: true
  retention_days: 90

azure:
  resource_group: production-rg

tags:
  monitoring: enabled
```

## Usage

```hcl
module "diagnostics" {
  source = "./azure/observability/diagnostics"
  config_file = "diagnostics.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Diagnostic setting ID |
| `diagnostic_setting_id` | Diagnostic setting ID |
