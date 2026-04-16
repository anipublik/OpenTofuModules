# AWS ElastiCache Module

Production-hardened ElastiCache Redis cluster with encryption and multi-AZ support.

## Features

- **Encryption** — At-rest and in-transit encryption enabled
- **Multi-AZ** — Automatic failover with replica nodes
- **Auth Token** — Redis AUTH for authentication
- **Automatic Backups** — Daily snapshots with configurable retention
- **Cluster Mode** — Sharding support for horizontal scaling
- **Private Subnet** — Deployed in private subnets only

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: session-cache
  team: platform
  cost_center: eng-001

cache:
  engine: redis
  engine_version: "7.0"
  node_type: cache.r6g.large
  num_cache_nodes: 2
  
  parameter_group_family: redis7
  port: 6379
  
  automatic_failover_enabled: true
  multi_az_enabled: true
  
  snapshot_retention_limit: 5
  snapshot_window: "03:00-05:00"
  maintenance_window: "sun:05:00-sun:07:00"
  
  auth_token_enabled: true

networking:
  subnet_ids:
    - subnet-11111111
    - subnet-22222222
  security_group_ids:
    - sg-app-servers

security:
  encryption_enabled: true
  transit_encryption_enabled: true

tags:
  data_classification: sensitive
```

## Usage

```hcl
module "elasticache" {
  source = "./aws/storage/elasticache"
  config_file = "elasticache-redis.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | ElastiCache cluster ID |
| `resource_arn` | ElastiCache cluster ARN |
| `cache_nodes` | List of cache node endpoints |
| `configuration_endpoint` | Configuration endpoint for cluster mode |
| `primary_endpoint` | Primary endpoint address |
