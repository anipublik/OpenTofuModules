# GCP CDN Module

Production-hardened Cloud CDN with backend buckets.

## Features

- **Edge Caching** — Global content delivery
- **Cache Policies** — TTL configuration
- **Negative Caching** — Error response caching
- **SSL** — HTTPS support
- **Custom Headers** — Cache key customization

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: static-cdn
  team: platform
  cost_center: eng-001

cdn:
  backend_buckets:
    - name: static-assets
      bucket_name: static-assets-bucket
      cdn_policy:
        cache_mode: CACHE_ALL_STATIC
        default_ttl: 3600
        max_ttl: 86400
        client_ttl: 3600
        negative_caching: true
  
  enable_http: true
  enable_https: true
  ssl_certificates:
    - projects/my-project/global/sslCertificates/cdn-cert
  
  ip_version: IPV4

gcp:
  project_id: my-project

tags:
  application: cdn
```

## Usage

```hcl
module "cdn" {
  source = "./gcp/network/cdn"
  config_file = "cdn.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | URL map ID |
| `ip_address` | CDN IP address |
| `backend_bucket_ids` | Map of backend bucket IDs |
