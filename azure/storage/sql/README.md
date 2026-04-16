# Azure SQL Database Module

Production-hardened Azure SQL Database with encryption, backups, and threat detection.

## Features

- **Encryption** — Transparent Data Encryption (TDE)
- **Automated Backups** — Point-in-time restore
- **Threat Detection** — Advanced threat protection
- **Zone Redundancy** — High availability
- **Firewall Rules** — IP and VNet rules
- **Azure AD Authentication** — Managed identity support

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-database
  team: platform
  cost_center: eng-001

database:
  version: "12.0"
  admin_username: sqladmin
  admin_password: "{{secret}}"
  
  sku_name: S3
  max_size_gb: 250
  
  azuread_admin_login: admin@example.com
  azuread_admin_object_id: 00000000-0000-0000-0000-000000000000
  
  weekly_retention: P1W
  monthly_retention: P1M
  yearly_retention: P1Y
  
  threat_detection_emails:
    - security@example.com

networking:
  firewall_rules:
    - name: office
      start_ip: 203.0.113.1
      end_ip: 203.0.113.254
  subnet_ids:
    - /subscriptions/.../subnets/database

security:
  public_access: false
  encryption_enabled: true

reliability:
  zone_redundant: true
  backup_retention_days: 7

azure:
  resource_group: production-rg

tags:
  data_classification: critical
```

## Usage

```hcl
module "sql" {
  source = "./azure/storage/sql"
  config_file = "sql.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | SQL Database ID |
| `server_fqdn` | SQL Server FQDN |
| `database_name` | SQL Database name |
