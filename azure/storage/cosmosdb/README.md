# Azure Cosmos DB Module

Production-hardened Azure Cosmos DB with multi-region replication and automatic failover.

## Features

- **Multi-Region** — Global distribution
- **Automatic Failover** — High availability
- **Consistency Levels** — Configurable consistency
- **Backup** — Continuous and periodic backups
- **Private Endpoints** — VNet integration
- **Zone Redundancy** — Availability zones

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-cosmos
  team: platform
  cost_center: eng-001

cosmosdb:
  kind: GlobalDocumentDB
  consistency_level: Session
  
  additional_locations:
    - location: westus
      failover_priority: 1
      zone_redundant: false
  
  enable_automatic_failover: true
  enable_multiple_write_locations: false
  
  backup_type: Periodic
  backup_interval_minutes: 240
  backup_retention_hours: 8
  
  databases:
    - name: appdb
      throughput: 400
      containers:
        - name: users
          partition_key_path: /userId
          throughput: 400

networking:
  subnet_ids:
    - /subscriptions/.../subnets/cosmos
  allowed_ip_ranges:
    - 203.0.113.0/24

security:
  public_access: false

reliability:
  zone_redundant: true

azure:
  resource_group: production-rg

tags:
  data_classification: sensitive
```

## Usage

```hcl
module "cosmosdb" {
  source = "./azure/storage/cosmosdb"
  config_file = "cosmosdb.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Cosmos DB account ID |
| `endpoint` | Cosmos DB endpoint |
| `database_ids` | Map of database IDs |
