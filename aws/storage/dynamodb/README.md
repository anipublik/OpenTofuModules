# AWS DynamoDB Module

Production-hardened DynamoDB table with encryption, point-in-time recovery, and auto-scaling.

## Features

- **Encryption at Rest** — KMS encryption enabled by default
- **Point-in-Time Recovery** — Continuous backups for 35 days
- **Auto-scaling** — Automatic capacity scaling based on utilization
- **Global Tables** — Multi-region replication support
- **DynamoDB Streams** — Change data capture for event-driven architectures
- **Deletion Protection** — Prevents accidental table deletion

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: user-data
  team: platform
  cost_center: eng-001

table:
  billing_mode: PAY_PER_REQUEST  # or PROVISIONED
  hash_key: userId
  range_key: timestamp
  
  attributes:
    - name: userId
      type: S
    - name: timestamp
      type: N
    - name: status
      type: S
  
  global_secondary_indexes:
    - name: status-index
      hash_key: status
      range_key: timestamp
      projection_type: ALL
  
  stream_enabled: true
  stream_view_type: NEW_AND_OLD_IMAGES
  
  point_in_time_recovery: true
  
  ttl:
    enabled: true
    attribute_name: expiresAt

security:
  encryption_enabled: true
  deletion_protection: true

tags:
  data_classification: sensitive
```

## Usage

```hcl
module "dynamodb" {
  source = "./aws/storage/dynamodb"
  config_file = "dynamodb-table.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | DynamoDB table name |
| `resource_arn` | DynamoDB table ARN |
| `table_name` | DynamoDB table name |
| `stream_arn` | DynamoDB stream ARN |
