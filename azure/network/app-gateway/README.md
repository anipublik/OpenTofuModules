# Azure Application Gateway Module

Production-hardened Application Gateway with WAF and auto-scaling.

## Features

- **WAF** — Web Application Firewall
- **SSL Termination** — HTTPS offloading
- **Auto-scaling** — Dynamic scaling
- **Multi-site Hosting** — Multiple backends
- **Health Probes** — Backend monitoring

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: api-gateway
  team: platform
  cost_center: eng-001

app_gateway:
  sku:
    name: WAF_v2
    tier: WAF_v2
    capacity: 2
  
  availability_zones:
    - 1
    - 2
    - 3
  
  ssl_certificates:
    - name: api-cert
      key_vault_secret_id: https://vault.vault.azure.net/secrets/cert
  
  enable_waf: true
  waf:
    mode: Prevention
    rule_set_version: "3.2"

networking:
  subnet_id: /subscriptions/.../subnets/appgw

azure:
  resource_group: production-rg

tags:
  application: api
```

## Usage

```hcl
module "app_gateway" {
  source = "./azure/network/app-gateway"
  config_file = "app-gateway.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Application Gateway ID |
| `public_ip_address` | Public IP address |
