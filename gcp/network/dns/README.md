# GCP DNS Module

Production-hardened Cloud DNS with DNSSEC and private zones.

## Features

- **Public Zones** — Internet-facing DNS
- **Private Zones** — VPC DNS resolution
- **DNSSEC** — Domain signing
- **Record Types** — A, AAAA, CNAME, MX, TXT

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: example-com
  team: platform
  cost_center: eng-001

dns:
  dns_name: example.com.
  create_zone: true
  visibility: public
  
  enable_dnssec: true
  
  records:
    - name: www.example.com.
      type: A
      ttl: 300
      rrdatas:
        - 203.0.113.1
    
    - name: api.example.com.
      type: CNAME
      ttl: 300
      rrdatas:
        - api.run.app.
  
  create_private_zone: false
  private_zone_name: internal.example.com.
  private_networks:
    - projects/my-project/global/networks/main

gcp:
  project_id: my-project

tags:
  domain: example.com
```

## Usage

```hcl
module "dns" {
  source = "./gcp/network/dns"
  config_file = "dns.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | DNS zone ID |
| `zone_name` | DNS zone name |
| `name_servers` | DNS zone name servers |
