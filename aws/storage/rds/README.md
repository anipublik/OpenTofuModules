# AWS RDS Module

Production-hardened RDS database with encryption, automated backups, and multi-AZ deployment.

## Features

- **Encryption at Rest** — KMS encryption enabled by default
- **Multi-AZ** — High availability with automatic failover
- **Automated Backups** — Daily backups with configurable retention
- **Enhanced Monitoring** — 60-second granularity monitoring
- **Performance Insights** — Query performance analysis
- **Deletion Protection** — Prevents accidental database deletion
- **Private Subnet** — Database deployed in private subnets only

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: app-db
  team: platform
  cost_center: eng-001

database:
  engine: postgres
  engine_version: "15.4"
  instance_class: db.r6g.xlarge
  allocated_storage: 100
  max_allocated_storage: 1000
  storage_encrypted: true
  
  database_name: appdb
  master_username: dbadmin
  master_password: "{{secret}}"  # Reference from Secrets Manager
  
  multi_az: true
  
  backup_retention_period: 7
  backup_window: "03:00-04:00"
  maintenance_window: "sun:04:00-sun:05:00"
  
  performance_insights_enabled: true
  enabled_cloudwatch_logs_exports:
    - postgresql
    - upgrade

networking:
  vpc_id: vpc-12345678
  subnet_ids:
    - subnet-11111111
    - subnet-22222222
  allowed_security_groups:
    - sg-app-servers

security:
  encryption_enabled: true
  deletion_protection: true
  publicly_accessible: false

tags:
  data_classification: sensitive
```

## Usage

```hcl
module "rds" {
  source = "./aws/storage/rds"
  config_file = "rds-database.yaml"
}

output "endpoint" {
  value = module.rds.db_endpoint
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | RDS instance identifier |
| `resource_arn` | RDS instance ARN |
| `db_endpoint` | Database connection endpoint |
| `db_port` | Database port |
| `db_name` | Database name |
