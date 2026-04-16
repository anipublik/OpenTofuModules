# GCP Load Balancing Module

Production-hardened Global Load Balancer with CDN and SSL.

## Features

- **Global Load Balancing** — Multi-region routing
- **CDN** — Edge caching
- **SSL Termination** — HTTPS offloading
- **Health Checks** — Backend monitoring
- **Cloud Armor** — DDoS protection

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: api-lb
  team: platform
  cost_center: eng-001

load_balancer:
  type: EXTERNAL
  ip_version: IPV4
  
  backends:
    - name: api-backend
      protocol: HTTPS
      port_name: https
      timeout_sec: 30
      enable_cdn: true
      instance_groups:
        - projects/my-project/zones/us-central1-a/instanceGroups/api-ig
      health_check:
        protocol: HTTPS
        port: 443
        path: /health
        check_interval_sec: 10
        timeout_sec: 5
  
  enable_http: true
  enable_https: true
  ssl_certificates:
    - projects/my-project/global/sslCertificates/api-cert
  
  enable_logging: true
  log_sample_rate: 1.0

gcp:
  project_id: my-project

tags:
  application: api
```

## Usage

```hcl
module "load_balancing" {
  source = "./gcp/network/load-balancing"
  config_file = "load-balancing.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | URL map ID |
| `ip_address` | Load balancer IP |
| `backend_service_ids` | Map of backend service IDs |
