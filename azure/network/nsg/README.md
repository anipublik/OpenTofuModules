# Azure NSG Module

Production-hardened Network Security Group with security rules.

## Features

- **Inbound/Outbound Rules** — Traffic filtering
- **Priority-Based** — Rule ordering
- **Service Tags** — Azure service references
- **Application Security Groups** — Workload grouping

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-nsg
  team: platform
  cost_center: eng-001

nsg:
  rules:
    - name: allow-https
      priority: 100
      direction: Inbound
      access: Allow
      protocol: Tcp
      destination_port_range: 443
      source_address_prefix: Internet
      destination_address_prefix: "*"
    
    - name: deny-all-inbound
      priority: 4096
      direction: Inbound
      access: Deny
      protocol: "*"
      source_port_range: "*"
      destination_port_range: "*"
      source_address_prefix: "*"
      destination_address_prefix: "*"
  
  subnet_ids:
    - /subscriptions/.../subnets/app-subnet

azure:
  resource_group: production-rg

tags:
  security_tier: application
```

## Usage

```hcl
module "nsg" {
  source = "./azure/network/nsg"
  config_file = "nsg.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | NSG ID |
| `nsg_id` | NSG ID |
