# Azure Front Door Module

Production-hardened Azure Front Door with WAF and global load balancing.

## Features

- **Global Load Balancing** — Multi-region routing
- **WAF** — Web Application Firewall
- **SSL Offloading** — HTTPS termination
- **Caching** — Edge caching
- **Health Probes** — Backend monitoring

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: cdn
  team: platform
  cost_center: eng-001

frontdoor:
  sku_name: Standard_AzureFrontDoor
  
  endpoints:
    - name: api
  
  origin_groups:
    - name: api-origins
      load_balancing:
        sample_size: 4
        successful_samples_required: 3
      health_probe:
        protocol: Https
        path: /health
        interval_seconds: 30
  
  origins:
    - name: api-primary
      origin_group_index: 0
      host_name: api-primary.azurewebsites.net
      priority: 1
      weight: 1000
  
  routes:
    - name: default-route
      endpoint_index: 0
      origin_group_index: 0
      origin_indices:
        - 0
      patterns_to_match:
        - /*
      https_redirect_enabled: true
  
  enable_waf: true
  waf:
    mode: Prevention

azure:
  resource_group: production-rg

tags:
  application: cdn
```

## Usage

```hcl
module "front_door" {
  source = "./azure/network/front-door"
  config_file = "front-door.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Front Door ID |
| `endpoint_hostnames` | Map of endpoint hostnames |
