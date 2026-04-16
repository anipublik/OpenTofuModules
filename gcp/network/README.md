# GCP Network Modules

Production-hardened networking resources for GCP with VPC Flow Logs, Private Service Connect, and Cloud Armor.

## Modules

### [VPC](./vpc/README.md)
Virtual Private Cloud with:
- Custom mode VPC (no auto-created subnets)
- Regional subnets with secondary IP ranges
- Private Google Access enabled
- VPC Flow Logs
- Cloud Router and Cloud NAT
- Firewall rules

### [Firewall Rules](./firewall/README.md)
VPC firewall with:
- Deny-by-default ingress
- Priority-based rule ordering
- Service accounts as targets
- Network tags for targeting
- Logging enabled
- Rule descriptions required

### [Cloud Load Balancing](./load-balancing/README.md)
Global and regional load balancers:
- HTTP(S) Load Balancer with Cloud Armor
- TCP/SSL Proxy Load Balancer
- Internal Load Balancer
- Backend health checks
- SSL certificates from Certificate Manager
- CDN integration

### [Cloud DNS](./dns/README.md)
Managed DNS zones with:
- Public and private zones
- DNSSEC for public zones
- VPC peering for private zones
- Routing policies (geo, weighted, failover)
- Cloud Logging integration

### [Cloud CDN](./cdn/README.md)
Content delivery network with:
- Cache modes (CACHE_ALL_STATIC, USE_ORIGIN_HEADERS)
- Signed URLs and cookies
- Cache invalidation
- Custom cache keys
- Negative caching

## Common Configuration

All network modules share these YAML fields:

```yaml
meta:
  environment: production
  region: us-central1
  name: my-network
  team: platform
  cost_center: eng-001

gcp:
  project_id: my-gcp-project

network:
  auto_create_subnetworks: false
  subnets:
    - name: subnet-app
      ip_cidr_range: 10.0.1.0/24
      region: us-central1
      secondary_ip_ranges:
        - range_name: pods
          ip_cidr_range: 10.4.0.0/14
        - range_name: services
          ip_cidr_range: 10.8.0.0/20

security:
  flow_logs_enabled: true
  private_google_access: true
  public_access: false

labels:
  custom_label: value
```

## Security Defaults

| Control | VPC | Firewall | Load Balancing | DNS | CDN |
|---------|-----|----------|----------------|-----|-----|
| **Flow Logs** | ✓ | N/A | N/A | ✓ | N/A |
| **Cloud Armor** | N/A | N/A | ✓ | N/A | N/A |
| **Private Access** | ✓ | N/A | N/A | ✓ | N/A |
| **TLS Enforcement** | N/A | N/A | ✓ | ✓ | ✓ |
| **Logging** | ✓ | ✓ | ✓ | ✓ | ✓ |

## Private Google Access

The VPC module enables Private Google Access on all subnets, allowing:
- Cloud Storage
- BigQuery
- Container Registry / Artifact Registry
- Cloud APIs without public IPs

## Quick Start

```bash
# Example: Deploy a VPC
cd gcp/network/vpc
cp examples/basic/config.yaml my-vpc.yaml

# Edit config
vim my-vpc.yaml

# Deploy
cat > main.tf << 'EOF'
module "vpc" {
  source = "../../../gcp/network/vpc"
  config_file = "my-vpc.yaml"
}
EOF

tofu init && tofu apply
```

## Outputs

All network modules output:

```hcl
output "resource_id" { }
output "resource_name" { }
output "resource_self_link" { }
output "network_id" { }             # If applicable
output "subnet_ids" { }             # If applicable
```
