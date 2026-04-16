# AWS Network Modules

Production-hardened networking resources for AWS with flow logs, PrivateLink, and least-privilege security groups.

## Modules

### [VPC](./vpc/README.md)
Virtual Private Cloud with:
- Multi-AZ public and private subnets
- NAT gateways for private subnet internet access
- VPC endpoints for AWS services (S3, DynamoDB, ECR, Secrets Manager, KMS)
- VPC flow logs to CloudWatch
- DNS hostnames and resolution enabled
- DHCP options sets

### [Security Groups](./security-groups/README.md)
Firewall rules with:
- Deny-by-default ingress
- Least-privilege egress
- Description required for all rules
- No 0.0.0.0/0 ingress by default
- Rule validation

### [ALB](./alb/README.md)
Application Load Balancer with:
- HTTPS listener with ACM certificate
- HTTP to HTTPS redirect
- Access logs to S3
- WAF integration
- Target group health checks
- Deletion protection

### [NLB](./nlb/README.md)
Network Load Balancer with:
- TCP/UDP/TLS listeners
- Cross-zone load balancing
- Access logs to S3
- Target group health checks
- Static IP addresses

### [Route 53](./route53/README.md)
DNS zones with:
- Public and private hosted zones
- Health checks with failover
- Alias records for AWS resources
- DNSSEC for public zones
- Query logging

### [CloudFront](./cloudfront/README.md)
CDN distributions with:
- Origin access identity for S3
- Custom SSL certificate
- WAF integration
- Access logs to S3
- Geo-restriction
- Cache behaviors

## Common Configuration

All network modules share these YAML fields:

```yaml
meta:
  environment: production
  region: us-east-1
  name: my-network
  team: platform
  cost_center: eng-001

network:
  cidr_block: 10.0.0.0/16           # VPC CIDR
  availability_zones:
    - us-east-1a
    - us-east-1b
    - us-east-1c

security:
  flow_logs_enabled: true
  public_access: false              # No public ingress by default
  deletion_protection: true

tags:
  custom_tag: value
```

## Security Defaults

| Control | VPC | Security Groups | ALB | NLB | Route 53 | CloudFront |
|---------|-----|-----------------|-----|-----|----------|------------|
| **Flow Logs** | ✓ | N/A | N/A | N/A | ✓ | N/A |
| **Access Logs** | N/A | N/A | ✓ | ✓ | N/A | ✓ |
| **WAF Integration** | N/A | N/A | ✓ | N/A | N/A | ✓ |
| **TLS Enforcement** | N/A | N/A | ✓ | ✓ | ✓ | ✓ |
| **Deletion Protection** | N/A | N/A | ✓ | ✓ | N/A | N/A |

## VPC Endpoints

The VPC module includes these endpoints by default:

- **S3** (gateway endpoint) — Free
- **DynamoDB** (gateway endpoint) — Free
- **ECR API** (interface endpoint)
- **ECR Docker** (interface endpoint)
- **Secrets Manager** (interface endpoint)
- **KMS** (interface endpoint)
- **CloudWatch Logs** (interface endpoint)

## Quick Start

```bash
# Example: Deploy a VPC
cd aws/network/vpc
cp examples/basic/config.yaml my-vpc.yaml

# Edit config
vim my-vpc.yaml

# Deploy
cat > main.tf << 'EOF'
module "vpc" {
  source = "../../../aws/network/vpc"
  config_file = "my-vpc.yaml"
}
EOF

tofu init && tofu apply
```

## Outputs

All network modules output:

```hcl
output "resource_id" { }
output "resource_arn" { }
output "resource_name" { }
output "vpc_id" { }                 # If applicable
output "subnet_ids" { }             # If applicable
output "security_group_id" { }      # If applicable
```
