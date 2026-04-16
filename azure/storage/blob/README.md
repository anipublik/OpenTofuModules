# Azure Blob Storage Module

Production-hardened Azure Storage Account with encryption, versioning, and lifecycle policies.

## Features

- **Encryption** — Microsoft-managed or customer-managed keys
- **Versioning** — Blob versioning enabled
- **Soft Delete** — Blob and container soft delete
- **Lifecycle Management** — Automated tiering
- **Network Rules** — VNet and IP restrictions
- **Private Endpoints** — Private connectivity

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: data-storage
  team: platform
  cost_center: eng-001

storage:
  account_tier: Standard
  replication_type: GRS
  account_kind: StorageV2
  access_tier: Hot
  
  versioning_enabled: true
  soft_delete_retention_days: 7
  container_soft_delete_retention_days: 7
  
  containers:
    - name: data
      access_type: private
    - name: backups
      access_type: private
  
  lifecycle_rules:
    - name: archive-old-data
      enabled: true
      prefix_match:
        - data/
      tier_to_cool_days: 30
      tier_to_archive_days: 90
      delete_after_days: 365

networking:
  allowed_ip_ranges:
    - 203.0.113.0/24
  subnet_ids:
    - /subscriptions/.../subnets/app-subnet

security:
  public_access: false
  encryption_enabled: true

azure:
  resource_group: production-rg

tags:
  data_classification: sensitive
```

## Usage

```hcl
module "blob" {
  source = "./azure/storage/blob"
  config_file = "blob.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Storage account ID |
| `storage_account_name` | Storage account name |
| `primary_blob_endpoint` | Primary blob endpoint |
| `container_ids` | Map of container IDs |
