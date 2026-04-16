# AWS Storage Modules

Production-hardened storage resources for AWS with encryption, backups, and multi-AZ replication.

## Modules

### [S3](./s3/README.md)
Object storage buckets with:
- Server-side encryption (SSE-S3 or SSE-KMS)
- Versioning enabled
- Public access block
- Lifecycle policies (transition to IA, Glacier, expiration)
- Intelligent tiering
- Bucket logging
- Object lock for compliance

### [RDS](./rds/README.md)
Managed relational databases (MySQL, PostgreSQL, Aurora) with:
- Storage encryption with KMS
- Automated backups with configurable retention
- Multi-AZ deployment
- Read replicas
- Enhanced monitoring
- Performance Insights
- Parameter groups tuned for production

### [DynamoDB](./dynamodb/README.md)
NoSQL tables with:
- Encryption at rest with KMS
- Point-in-time recovery
- On-demand or provisioned billing
- Auto-scaling (provisioned mode)
- Global tables for multi-region
- DynamoDB Streams
- Backup retention

### [ElastiCache](./elasticache/README.md)
In-memory caching (Redis, Memcached) with:
- Encryption in transit (TLS)
- Encryption at rest (Redis only)
- Multi-AZ with automatic failover
- Cluster mode for Redis
- Automated backups (Redis only)
- CloudWatch metrics

## Common Configuration

All storage modules share these YAML fields:

```yaml
meta:
  environment: production
  region: us-east-1
  name: my-storage
  team: platform
  cost_center: eng-001

storage:
  size: 100                          # Size in GB (varies by module)
  storage_type: gp3                  # EBS type for RDS
  iops: 3000                         # Provisioned IOPS (if applicable)

encryption:
  enabled: true
  kms_key_id: "arn:aws:kms:..."      # Optional — use custom KMS key

backup:
  enabled: true
  retention_days: 7
  backup_window: "03:00-04:00"       # UTC
  maintenance_window: "mon:04:00-mon:05:00"

reliability:
  multi_az: true
  deletion_protection: true

security:
  encryption_enabled: true
  public_access: false
  audit_logging: true

tags:
  custom_tag: value
```

## Security Defaults

| Control | S3 | RDS | DynamoDB | ElastiCache |
|---------|-----|-----|----------|-------------|
| **Encryption at Rest** | ✓ | ✓ | ✓ | ✓ (Redis) |
| **Encryption in Transit** | ✓ | ✓ | ✓ | ✓ |
| **Public Access Block** | ✓ | ✓ | N/A | N/A |
| **Versioning** | ✓ | N/A | N/A | N/A |
| **Backup** | N/A | ✓ | ✓ | ✓ (Redis) |
| **Multi-AZ** | N/A | ✓ | ✓ | ✓ |

## Performance Defaults

- **S3 Intelligent Tiering** — Automatically moves objects between access tiers
- **RDS Performance Insights** — Enabled for query performance monitoring
- **DynamoDB Auto-Scaling** — Adjusts capacity based on traffic
- **ElastiCache Cluster Mode** — Horizontal scaling for Redis

## Quick Start

```bash
# Example: Deploy an RDS PostgreSQL database
cd aws/storage/rds
cp examples/basic/config.yaml my-db.yaml

# Edit config
vim my-db.yaml

# Deploy
cat > main.tf << 'EOF'
module "rds" {
  source = "../../../aws/storage/rds"
  config_file = "my-db.yaml"
}
EOF

tofu init && tofu apply
```

## Outputs

All storage modules output:

```hcl
output "resource_id" { }
output "resource_arn" { }
output "resource_name" { }
output "connection_endpoint" { }    # RDS, ElastiCache, DynamoDB
output "connection_port" { }        # RDS, ElastiCache
```
