# Azure Redis Cache Module

Production-hardened Azure Cache for Redis with encryption and zone redundancy.

## Features

- **Encryption** — TLS encryption in transit
- **Zone Redundancy** — High availability
- **Persistence** — RDB snapshots
- **Clustering** — Premium tier clustering
- **Firewall Rules** — IP restrictions
- **Private Endpoint** — VNet integration

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: session-cache
  team: platform
  cost_center: eng-001

redis:
  capacity: 1
  family: C
  sku_name: Standard
  
  maxmemory_policy: allkeys-lru
  
  patch_day: Sunday
  patch_hour: 2

networking:
  firewall_rules:
    - name: office
      start_ip: 203.0.113.1
      end_ip: 203.0.113.254

security:
  public_access: false

reliability:
  zone_redundant: false
  backup_enabled: false

azure:
  resource_group: production-rg

tags:
  data_classification: sensitive
```

## Usage

```hcl
module "redis" {
  source = "./azure/storage/redis"
  config_file = "redis.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Redis cache ID |
| `hostname` | Redis hostname |
| `ssl_port` | Redis SSL port |
