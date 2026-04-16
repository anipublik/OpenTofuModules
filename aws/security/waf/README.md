# AWS WAF Module

Production-hardened WAF web ACL with managed rule groups and custom rules.

## Features

- **Managed Rule Groups** — AWS and marketplace rules
- **Custom Rules** — IP sets, geo blocking, rate limiting
- **Logging** — CloudWatch Logs or S3 logging
- **Metrics** — CloudWatch metrics for monitoring
- **Regional/Global** — Support for ALB and CloudFront
- **IP Reputation Lists** — Automatic threat intelligence

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: api-protection
  team: platform
  cost_center: eng-001

waf:
  scope: REGIONAL  # or CLOUDFRONT
  
  default_action: allow
  
  managed_rule_groups:
    - name: AWSManagedRulesCommonRuleSet
      priority: 1
      override_action: none
    
    - name: AWSManagedRulesKnownBadInputsRuleSet
      priority: 2
      override_action: none
    
    - name: AWSManagedRulesSQLiRuleSet
      priority: 3
      override_action: none
  
  custom_rules:
    - name: rate-limit
      priority: 10
      action: block
      statement:
        rate_based_statement:
          limit: 2000
          aggregate_key_type: IP
    
    - name: geo-block
      priority: 20
      action: block
      statement:
        geo_match_statement:
          country_codes:
            - CN
            - RU
  
  logging:
    enabled: true
    log_destination: arn:aws:logs:us-east-1:123456789012:log-group:aws-waf-logs

tags:
  application: api
```

## Usage

```hcl
module "waf" {
  source = "./aws/security/waf"
  config_file = "waf.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | WAF web ACL ID |
| `resource_arn` | WAF web ACL ARN |
| `web_acl_id` | WAF web ACL ID |
| `web_acl_arn` | WAF web ACL ARN |
| `web_acl_capacity` | WAF web ACL capacity |
