# Azure VNet Module

Production-hardened Azure Virtual Network with subnets, NSGs, and flow logs.

## Features

- **Multiple Subnets** — Public and private subnets
- **Network Security Groups** — Per-subnet NSGs
- **Flow Logs** — Traffic analytics
- **Service Endpoints** — Azure service connectivity
- **VNet Peering** — Cross-VNet connectivity

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: main
  team: platform
  cost_center: eng-001

network:
  address_space:
    - 10.0.0.0/16
  
  subnets:
    - name: app-subnet
      address_prefix: 10.0.1.0/24
      service_endpoints:
        - Microsoft.Storage
        - Microsoft.Sql
    - name: data-subnet
      address_prefix: 10.0.2.0/24

security:
  flow_logs_enabled: true

azure:
  resource_group: production-rg

tags:
  network_tier: core
```

## Usage

```hcl
module "vnet" {
  source = "./azure/network/vnet"
  config_file = "vnet.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | VNet ID |
| `vnet_id` | VNet ID |
| `subnet_ids` | Map of subnet IDs |
