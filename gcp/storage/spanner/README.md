# GCP Spanner Module

Production-hardened Cloud Spanner with encryption and IAM.

## Features

- **Global Distribution** — Multi-region replication
- **Strong Consistency** — ACID transactions
- **Encryption** — Customer-managed keys
- **Automatic Scaling** — Processing units
- **Deletion Protection** — Prevent accidental deletion

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: app-database
  team: platform
  cost_center: eng-001

spanner:
  config: regional-us-central1
  num_nodes: 1
  
  databases:
    - name: appdb
      version_retention_period: 1h
      deletion_protection: true
      kms_key_name: projects/my-project/locations/us-central1/keyRings/spanner/cryptoKeys/db
      ddl:
        - CREATE TABLE Users (UserId INT64, Name STRING(MAX)) PRIMARY KEY (UserId)
  
  iam_bindings:
    - database_index: 0
      role: roles/spanner.databaseReader
      members:
        - serviceAccount:app@my-project.iam.gserviceaccount.com

security:
  encryption_enabled: true

gcp:
  project_id: my-project

tags:
  data_classification: critical
```

## Usage

```hcl
module "spanner" {
  source = "./gcp/storage/spanner"
  config_file = "spanner.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Spanner instance ID |
| `instance_name` | Instance name |
| `database_ids` | Map of database IDs |
