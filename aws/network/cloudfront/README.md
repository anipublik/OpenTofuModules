# AWS CloudFront Module

Production-hardened CloudFront distribution with HTTPS, WAF, and access logs.

## Features

- **HTTPS Only** — Redirect HTTP to HTTPS
- **Custom SSL Certificate** — ACM certificate support
- **WAF Integration** — AWS WAF web ACL association
- **Access Logs** — S3 logging enabled
- **Origin Shield** — Additional caching layer
- **Geo Restriction** — Whitelist/blacklist countries
- **Custom Error Pages** — 404, 500 error handling

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: cdn
  team: platform
  cost_center: eng-001

distribution:
  enabled: true
  price_class: PriceClass_All
  http_version: http2and3
  
  aliases:
    - cdn.example.com
  
  viewer_certificate:
    acm_certificate_arn: arn:aws:acm:us-east-1:123456789012:certificate/...
    ssl_support_method: sni-only
    minimum_protocol_version: TLSv1.2_2021
  
  origins:
    - domain_name: origin.example.com
      origin_id: primary
      custom_origin_config:
        http_port: 80
        https_port: 443
        origin_protocol_policy: https-only
        origin_ssl_protocols:
          - TLSv1.2
  
  default_cache_behavior:
    target_origin_id: primary
    viewer_protocol_policy: redirect-to-https
    allowed_methods:
      - GET
      - HEAD
      - OPTIONS
    cached_methods:
      - GET
      - HEAD
    compress: true
    default_ttl: 3600
    max_ttl: 86400
    min_ttl: 0
  
  logging:
    enabled: true
    bucket: cloudfront-logs.s3.amazonaws.com
    prefix: cdn/
  
  waf_acl_id: arn:aws:wafv2:us-east-1:123456789012:global/webacl/...

tags:
  application: cdn
```

## Usage

```hcl
module "cloudfront" {
  source = "./aws/network/cloudfront"
  config_file = "cloudfront.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | CloudFront distribution ID |
| `resource_arn` | CloudFront distribution ARN |
| `distribution_domain_name` | CloudFront domain name |
| `distribution_hosted_zone_id` | CloudFront hosted zone ID |
