# GCP Cloud SQL Module

Production-hardened Cloud SQL instance with automated backups, point-in-time recovery, and IAM authentication.

## Features

- **Automated Backups** — Daily backups with configurable retention
- **Point-in-Time Recovery** — Restore to any point within retention period
- **High Availability** — Regional (multi-zone) deployment option
- **Private IP** — VPC-native connectivity without public exposure
- **SSL Required** — Encrypted connections enforced
- **IAM Authentication** — Cloud IAM-based database authentication
- **Query Insights** — Performance monitoring and query analysis
- **Maintenance Windows** — Controlled update scheduling
- **Deletion Protection** — Prevent accidental instance deletion

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: app-db
  team: backend
  cost_center: eng-002

gcp:
  project_id: my-gcp-project

database:
  database_version: POSTGRES_15        # or MYSQL_8_0, SQLSERVER_2019_STANDARD
  tier: db-custom-4-16384              # 4 vCPU, 16GB RAM
  disk_type: PD_SSD                    # or PD_HDD
  disk_size: 100                       # GB
  disk_autoresize: true
  
  backup_start_time: "03:00"           # UTC
  maintenance_day: 7                   # Sunday
  maintenance_hour: 4                  # 4 AM UTC
  
  databases:
    - app_production
    - app_analytics
  
  users:
    - name: app_user
      type: BUILT_IN
      password: null                   # Use Secret Manager
    - name: admin@example.com
      type: CLOUD_IAM_USER

networking:
  ipv4_enabled: false                  # No public IP
  private_network: projects/my-project/global/networks/platform-vpc
  authorized_networks: []              # Only if ipv4_enabled: true

reliability:
  multi_az: true                       # Regional HA
  point_in_time_recovery: true
  backup_retention_days: 7

security:
  deletion_protection: true
  encryption_enabled: true
  kms_key_id: null                     # Optional CMEK

tags:
  project: backend
  compliance: pci-dss
```

## Usage

```hcl
module "cloudsql" {
  source = "./gcp/storage/cloudsql"
  config_file = "cloudsql.yaml"
}

output "instance_connection_name" {
  value = module.cloudsql.instance_connection_name
}

output "private_ip_address" {
  value = module.cloudsql.private_ip_address
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | Cloud SQL instance ID |
| `instance_name` | Cloud SQL instance name |
| `instance_connection_name` | Connection name for Cloud SQL Proxy |
| `private_ip_address` | Private IP address |
| `public_ip_address` | Public IP address (if enabled) |
| `database_names` | List of created database names |

## Database Versions

Supported database engines:

- **PostgreSQL**: `POSTGRES_15`, `POSTGRES_14`, `POSTGRES_13`
- **MySQL**: `MYSQL_8_0`, `MYSQL_5_7`
- **SQL Server**: `SQLSERVER_2019_STANDARD`, `SQLSERVER_2019_ENTERPRISE`

## Machine Types

Common tier configurations:

- `db-f1-micro` — 1 shared vCPU, 0.6GB RAM (dev/test only)
- `db-g1-small` — 1 shared vCPU, 1.7GB RAM (dev/test only)
- `db-custom-2-8192` — 2 vCPU, 8GB RAM
- `db-custom-4-16384` — 4 vCPU, 16GB RAM
- `db-custom-8-32768` — 8 vCPU, 32GB RAM

## Connecting to Cloud SQL

### Using Cloud SQL Proxy

```bash
cloud-sql-proxy \
  my-project:us-central1:app-db-production \
  --port 5432
```

### Using Private IP (from VPC)

```bash
psql "host=10.0.0.3 port=5432 dbname=app_production user=app_user"
```

### Using IAM Authentication

```bash
gcloud sql connect app-db-production \
  --user=admin@example.com \
  --database=app_production
```

## Security Considerations

- **Private IP Only** — Set `ipv4_enabled: false` for maximum security
- **SSL Required** — All connections must use SSL/TLS
- **IAM Authentication** — Use Cloud IAM users instead of database passwords
- **Deletion Protection** — Always enable in production
- **CMEK** — Use customer-managed encryption keys for compliance requirements
- **Authorized Networks** — If public IP required, restrict to known IPs only

## High Availability

Regional (HA) configuration:

```yaml
reliability:
  multi_az: true                       # Enables regional HA
  point_in_time_recovery: true
  backup_retention_days: 30
```

- **Automatic Failover** — Failover to standby in different zone
- **Zero Data Loss** — Synchronous replication
- **RPO: 0 seconds** — No data loss on failover
- **RTO: ~60 seconds** — Automatic failover time

## Backup and Recovery

**Automated Backups:**
- Daily backups at configured time
- Configurable retention (1-365 days)
- Stored in multi-regional location

**Point-in-Time Recovery:**
- Restore to any second within retention period
- Requires transaction log retention
- Creates new instance from backup

**Manual Backups:**
```bash
gcloud sql backups create \
  --instance=app-db-production \
  --description="Pre-migration backup"
```

## Cost Optimization

- **Shared-Core Instances** — Use `db-f1-micro` or `db-g1-small` for dev/test
- **PD-HDD** — Use `disk_type: PD_HDD` for non-performance-critical workloads
- **Backup Retention** — Reduce retention days to minimize storage costs
- **Zonal Instances** — Use `multi_az: false` for non-critical databases
- **Committed Use Discounts** — Purchase 1-year or 3-year commitments for 20-50% savings

## Troubleshooting

**Can't connect from Compute Engine:**
- Verify instance is in same VPC as Cloud SQL
- Check VPC has Private Service Connection configured
- Ensure firewall rules allow traffic to Cloud SQL IP range

**Slow query performance:**
- Enable Query Insights to identify slow queries
- Check `gcloud sql operations list` for maintenance operations
- Review disk I/O metrics in Cloud Monitoring
- Consider upgrading tier or switching to PD-SSD

**Backup failures:**
- Verify sufficient disk space for backup operation
- Check Cloud SQL service account has required permissions
- Review Cloud Logging for detailed error messages

## Additional Resources

- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy)
- [IAM Authentication](https://cloud.google.com/sql/docs/postgres/authentication)
- [High Availability](https://cloud.google.com/sql/docs/postgres/high-availability)
