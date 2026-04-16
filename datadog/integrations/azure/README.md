# Datadog Azure Integration

Integrate Datadog with Azure Monitor.

## Features

- **Service Principal Auth** — Secure authentication
- **Resource Filtering** — Filter by resource groups
- **Tag-Based Filtering** — Filter by tags

## Usage

```hcl
module "azure_integration" {
  source = "./datadog/integrations/azure"
  config_file = "integrations/azure.yaml"
}
```
