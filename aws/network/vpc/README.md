# AWS VPC Module

Production-hardened VPC with public/private subnets, NAT gateways, and flow logs.

## Features

- **Multi-AZ** — Subnets across 3 availability zones
- **NAT Gateways** — High-availability NAT in each AZ
- **VPC Flow Logs** — Network traffic logging to CloudWatch
- **VPC Endpoints** — S3, DynamoDB, ECR, Secrets Manager endpoints
- **Network ACLs** — Stateless firewall rules
- **DNS Support** — DNS hostnames and resolution enabled

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: main
  team: platform
  cost_center: eng-001

vpc:
  cidr_block: 10.0.0.0/16
  enable_dns_hostnames: true
  enable_dns_support: true
  
  public_subnets:
    - cidr: 10.0.1.0/24
      az: us-east-1a
    - cidr: 10.0.2.0/24
      az: us-east-1b
    - cidr: 10.0.3.0/24
      az: us-east-1c
  
  private_subnets:
    - cidr: 10.0.11.0/24
      az: us-east-1a
    - cidr: 10.0.12.0/24
      az: us-east-1b
    - cidr: 10.0.13.0/24
      az: us-east-1c
  
  nat_gateway:
    enabled: true
    single_nat: false  # One NAT per AZ for HA
  
  vpc_endpoints:
    - s3
    - dynamodb
    - ecr.api
    - ecr.dkr
    - secretsmanager
  
  flow_logs:
    enabled: true
    retention_days: 30

security:
  flow_logs_enabled: true

tags:
  network_tier: core
```

## Usage

```hcl
module "vpc" {
  source = "./aws/network/vpc"
  config_file = "vpc.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | VPC ID |
| `resource_arn` | VPC ARN |
| `vpc_id` | VPC ID |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_ids` | List of NAT gateway IDs |
