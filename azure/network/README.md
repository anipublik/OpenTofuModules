# Azure Network Modules

Production-hardened networking resources for Azure with NSG flow logs, Private Link, and DDoS protection.

## Modules

### [VNet](./vnet/README.md)
Virtual networks with:
- Multiple subnets with service endpoints
- NSG associations
- DDoS protection (Standard or Basic)
- VNet peering
- DNS servers configuration
- Address space management

### [NSG](./nsg/README.md)
Network security groups with:
- Deny-by-default rules
- Priority-based rule ordering
- Application security groups
- Service tags for Azure services
- Flow logs to Log Analytics
- Rule descriptions required

### [Application Gateway](./app-gateway/README.md)
Layer 7 load balancer with:
- WAF v2 with OWASP rules
- SSL termination with Key Vault certificates
- HTTP to HTTPS redirect
- Backend health probes
- URL-based routing
- Autoscaling

### [Azure DNS](./dns/README.md)
DNS zones with:
- Public and private zones
- Alias records for Azure resources
- DNSSEC (public zones)
- VNet links for private zones
- SOA and NS record management

### [Azure Front Door](./front-door/README.md)
Global CDN and load balancer with:
- WAF policies
- Custom domains with SSL
- Caching rules
- Origin health probes
- Geo-filtering
- Rate limiting

## Common Configuration

All network modules share these YAML fields:

```yaml
meta:
  environment: production
  region: eastus
  name: my-network
  team: platform
  cost_center: eng-001

azure:
  resource_group: rg-platform-prod

network:
  address_space:
    - 10.0.0.0/16
  subnets:
    - name: subnet-app
      address_prefix: 10.0.1.0/24
    - name: subnet-data
      address_prefix: 10.0.2.0/24

security:
  flow_logs_enabled: true
  ddos_protection: Standard
  public_access: false

tags:
  custom_tag: value
```

## Security Defaults

| Control | VNet | NSG | App Gateway | DNS | Front Door |
|---------|------|-----|-------------|-----|------------|
| **Flow Logs** | N/A | ✓ | N/A | N/A | N/A |
| **DDoS Protection** | ✓ | N/A | ✓ | N/A | ✓ |
| **WAF** | N/A | N/A | ✓ | N/A | ✓ |
| **TLS Enforcement** | N/A | N/A | ✓ | ✓ | ✓ |
| **Private Endpoints** | ✓ | N/A | N/A | ✓ | N/A |

## Service Endpoints

The VNet module includes these service endpoints by default:

- Microsoft.Storage
- Microsoft.Sql
- Microsoft.KeyVault
- Microsoft.ContainerRegistry
- Microsoft.AzureCosmosDB

## Quick Start

```bash
# Example: Deploy a VNet
cd azure/network/vnet
cp examples/basic/config.yaml my-vnet.yaml

# Edit config
vim my-vnet.yaml

# Deploy
cat > main.tf << 'EOF'
module "vnet" {
  source = "../../../azure/network/vnet"
  config_file = "my-vnet.yaml"
}
EOF

tofu init && tofu apply
```

## Outputs

All network modules output:

```hcl
output "resource_id" { }
output "resource_name" { }
output "vnet_id" { }                # If applicable
output "subnet_ids" { }             # If applicable
output "nsg_id" { }                 # If applicable
```
