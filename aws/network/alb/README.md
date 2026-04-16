# AWS ALB Module

Production-hardened Application Load Balancer with HTTPS, WAF, and access logs.

## Features

- **HTTPS** — SSL/TLS termination with ACM certificates
- **HTTP to HTTPS Redirect** — Automatic redirect rules
- **Access Logs** — S3 logging enabled
- **WAF Integration** — AWS WAF web ACL association
- **Health Checks** — Configurable health check parameters
- **Cross-Zone Load Balancing** — Enabled by default

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: api
  team: platform
  cost_center: eng-001

load_balancer:
  internal: false
  ip_address_type: ipv4
  
  subnets:
    - subnet-11111111
    - subnet-22222222
    - subnet-33333333
  
  security_groups:
    - sg-alb
  
  access_logs:
    enabled: true
    bucket: alb-logs-bucket
    prefix: api-alb
  
  listeners:
    - port: 80
      protocol: HTTP
      default_action:
        type: redirect
        redirect:
          protocol: HTTPS
          port: 443
          status_code: HTTP_301
    
    - port: 443
      protocol: HTTPS
      certificate_arn: arn:aws:acm:us-east-1:123456789012:certificate/...
      default_action:
        type: forward
        target_group: api-tg
  
  target_groups:
    - name: api-tg
      port: 8080
      protocol: HTTP
      health_check:
        path: /health
        interval: 30
        timeout: 5
        healthy_threshold: 2
        unhealthy_threshold: 3
  
  waf_acl_arn: arn:aws:wafv2:us-east-1:123456789012:regional/webacl/...

security:
  deletion_protection: true

tags:
  application: api
```

## Usage

```hcl
module "alb" {
  source = "./aws/network/alb"
  config_file = "alb.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | ALB ID |
| `resource_arn` | ALB ARN |
| `alb_dns_name` | ALB DNS name |
| `alb_zone_id` | ALB zone ID |
| `target_group_arns` | Map of target group ARNs |
