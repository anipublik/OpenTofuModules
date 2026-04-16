# Azure Log Analytics Module

Production-hardened Log Analytics workspace with solutions and saved searches.

## Features

- **Workspace** — Centralized logging
- **Solutions** — Pre-built analytics
- **Saved Searches** — Query templates
- **Data Retention** — Configurable retention
- **Private Access** — VNet integration

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: central-logs
  team: platform
  cost_center: eng-001

workspace:
  sku: PerGB2018
  retention_days: 90
  daily_quota_gb: -1
  
  internet_ingestion_enabled: false
  internet_query_enabled: false
  
  solutions:
    - SecurityInsights
    - Updates
    - AzureActivity
  
  saved_searches:
    - name: failed-logins
      category: Security
      display_name: Failed Login Attempts
      query: |
        SecurityEvent
        | where EventID == 4625
        | summarize count() by Account

azure:
  resource_group: production-rg

tags:
  logging_tier: central
```

## Usage

```hcl
module "log_analytics" {
  source = "./azure/observability/log-analytics"
  config_file = "log-analytics.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Workspace ID |
| `workspace_id` | Workspace ID |
| `workspace_resource_id` | Workspace resource ID |
