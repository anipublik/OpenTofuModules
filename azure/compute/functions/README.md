# Azure Functions Module

Production-hardened Azure Function App with managed identity and Application Insights.

## Features

- **Managed Identity** — System-assigned identity
- **Application Insights** — Performance monitoring
- **VNet Integration** — Private networking
- **Deployment Slots** — Blue-green deployments
- **Always On** — Keep function warm

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: data-processor
  team: platform
  cost_center: eng-001

function:
  os_type: Linux
  sku_name: EP1  # Elastic Premium
  runtime: python
  python_version: "3.9"
  always_on: true
  
  app_settings:
    FUNCTIONS_WORKER_RUNTIME: python
    DATABASE_URL: "{{secret}}"
  
  app_insights_connection_string: "InstrumentationKey=..."
  
  functions:
    - name: process-data
      bindings:
        - type: httpTrigger
          direction: in
          name: req
        - type: http
          direction: out
          name: res

azure:
  resource_group: production-rg

tags:
  application: data-pipeline
```

## Usage

```hcl
module "functions" {
  source = "./azure/compute/functions"
  config_file = "functions.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Function App ID |
| `function_app_id` | Function App ID |
| `default_hostname` | Function App hostname |
