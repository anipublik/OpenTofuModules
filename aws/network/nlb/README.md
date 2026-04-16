# AWS NLB Module

Production-hardened Network Load Balancer for TCP/UDP traffic with cross-zone load balancing.

## Features

- **TCP/UDP/TLS** — Layer 4 load balancing
- **Static IP** — Elastic IP addresses per AZ
- **Cross-Zone Load Balancing** — Distribute traffic across AZs
- **Connection Draining** — Graceful connection termination
- **Proxy Protocol** — Preserve client IP information
- **Access Logs** — S3 logging enabled

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: database
  team: platform
  cost_center: eng-001

load_balancer:
  internal: true
  ip_address_type: ipv4
  
  subnets:
    - subnet-11111111
    - subnet-22222222
  
  cross_zone_load_balancing: true
  
  access_logs:
    enabled: true
    bucket: nlb-logs-bucket
    prefix: db-nlb
  
  listeners:
    - port: 5432
      protocol: TCP
      default_action:
        type: forward
        target_group: postgres-tg
  
  target_groups:
    - name: postgres-tg
      port: 5432
      protocol: TCP
      health_check:
        protocol: TCP
        interval: 30
        healthy_threshold: 3
        unhealthy_threshold: 3
      
      deregistration_delay: 300
      proxy_protocol_v2: false

security:
  deletion_protection: true

tags:
  application: database
```

## Usage

```hcl
module "nlb" {
  source = "./aws/network/nlb"
  config_file = "nlb.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | NLB ID |
| `resource_arn` | NLB ARN |
| `nlb_dns_name` | NLB DNS name |
| `nlb_zone_id` | NLB zone ID |
| `target_group_arns` | Map of target group ARNs |
