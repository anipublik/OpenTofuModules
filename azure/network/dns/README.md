# Azure DNS Module

Production-hardened Azure DNS with public and private zones.

## Features

- **Public Zones** — Internet-facing DNS
- **Private Zones** — VNet DNS resolution
- **Record Types** — A, AAAA, CNAME, MX, TXT
- **VNet Links** — Private zone associations

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: example-com
  team: platform
  cost_center: eng-001

dns:
  zone_name: example.com
  create_zone: true
  
  records:
    - name: www
      type: A
      ttl: 300
      records:
        - 203.0.113.1
    
    - name: api
      type: CNAME
      ttl: 300
      records:
        - api.azurewebsites.net
  
  create_private_zone: false
  private_zone_name: internal.example.com
  vnet_links:
    - /subscriptions/.../virtualNetworks/main-vnet

azure:
  resource_group: production-rg

tags:
  domain: example.com
```

## Usage

```hcl
module "dns" {
  source = "./azure/network/dns"
  config_file = "dns.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | DNS zone ID |
| `name_servers` | DNS zone name servers |
