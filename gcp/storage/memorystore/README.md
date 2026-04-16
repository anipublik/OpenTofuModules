# GCP Memorystore Module

Production-hardened Memorystore for Redis with HA and persistence.

## Features

- **High Availability** — Standard tier with replicas
- **Auth** — Redis AUTH enabled
- **Transit Encryption** — TLS encryption
- **Persistence** — RDB snapshots
- **Read Replicas** — Read scaling

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: session-cache
  team: platform
  cost_center: eng-001

redis:
  tier: STANDARD_HA
  memory_size_gb: 5
  redis_version: REDIS_7_0
  
  auth_enabled: true
  transit_encryption_mode: SERVER_AUTHENTICATION
  
  replica_count: 1
  read_replicas_mode: READ_REPLICAS_ENABLED
  
  persistence_enabled: true
  persistence_config:
    mode: RDB
    snapshot_period: ONE_HOUR
  
  maintenance_policy:
    day: SUNDAY
    start_hour: 2
    start_minute: 0

networking:
  network: projects/my-project/global/networks/main

gcp:
  project_id: my-project

tags:
  data_classification: sensitive
```

## Usage

```hcl
module "memorystore" {
  source = "./gcp/storage/memorystore"
  config_file = "memorystore.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Redis instance ID |
| `redis_host` | Redis host |
| `redis_port` | Redis port |
