# AWS Route53 Module

Production-hardened Route53 hosted zone with health checks and query logging.

## Features

- **Public/Private Zones** — Support for both zone types
- **Health Checks** — Endpoint monitoring with failover
- **Query Logging** — CloudWatch Logs integration
- **DNSSEC** — Domain signing for security
- **Alias Records** — Integration with AWS resources
- **Weighted/Latency Routing** — Advanced routing policies

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: example-com
  team: platform
  cost_center: eng-001

zone:
  domain_name: example.com
  comment: Production DNS zone
  force_destroy: false
  
  vpc_id: null  # Set for private zone
  
  records:
    - name: www.example.com
      type: A
      alias:
        name: d123456789.cloudfront.net
        zone_id: Z2FDTNDATAQYW2
        evaluate_target_health: false
    
    - name: api.example.com
      type: A
      ttl: 300
      records:
        - 203.0.113.1
        - 203.0.113.2
    
    - name: _dmarc.example.com
      type: TXT
      ttl: 300
      records:
        - "v=DMARC1; p=reject; rua=mailto:dmarc@example.com"
  
  health_checks:
    - type: HTTPS
      fqdn: api.example.com
      port: 443
      resource_path: /health
      request_interval: 30
      failure_threshold: 3
  
  query_logging_enabled: true

tags:
  domain: example.com
```

## Usage

```hcl
module "route53" {
  source = "./aws/network/route53"
  config_file = "route53.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Route53 zone ID |
| `resource_arn` | Route53 zone ARN |
| `zone_id` | Route53 zone ID |
| `name_servers` | Route53 zone name servers |
