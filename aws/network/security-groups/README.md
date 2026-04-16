# AWS Security Groups Module

Production-hardened security groups with least-privilege rules.

## Features

- **Least Privilege** — Deny-all by default
- **Named Rules** — Descriptive rule names
- **Source Security Groups** — Reference other SGs
- **CIDR Blocks** — IP-based rules
- **Protocol Support** — TCP, UDP, ICMP, all protocols

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: app-servers
  team: platform
  cost_center: eng-001

security_group:
  vpc_id: vpc-12345678
  description: Security group for application servers
  
  ingress_rules:
    - description: HTTPS from ALB
      from_port: 443
      to_port: 443
      protocol: tcp
      source_security_group_id: sg-alb
    
    - description: HTTP from ALB
      from_port: 8080
      to_port: 8080
      protocol: tcp
      source_security_group_id: sg-alb
    
    - description: SSH from bastion
      from_port: 22
      to_port: 22
      protocol: tcp
      cidr_blocks:
        - 10.0.1.0/24
  
  egress_rules:
    - description: All outbound traffic
      from_port: 0
      to_port: 0
      protocol: -1
      cidr_blocks:
        - 0.0.0.0/0

tags:
  application: web-app
```

## Usage

```hcl
module "security_group" {
  source = "./aws/network/security-groups"
  config_file = "security-group.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Security group ID |
| `resource_arn` | Security group ARN |
| `security_group_id` | Security group ID |
| `security_group_name` | Security group name |
