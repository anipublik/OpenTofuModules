# Azure Key Vault Module

Production-hardened Azure Key Vault with RBAC, secrets, and keys.

## Features

- **Secrets Management** — Secure secret storage
- **Key Management** — Cryptographic keys
- **RBAC Authorization** — Role-based access
- **Soft Delete** — Recovery protection
- **Network Rules** — VNet and IP restrictions
- **Purge Protection** — Deletion protection

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-vault
  team: platform
  cost_center: eng-001

key_vault:
  sku: standard
  soft_delete_retention_days: 90
  enable_rbac_authorization: true
  
  enabled_for_disk_encryption: true
  enabled_for_deployment: false
  
  secrets:
    - name: database-password
      value: "{{secret}}"
  
  keys:
    - name: encryption-key
      key_type: RSA
      key_size: 2048

networking:
  allowed_ip_ranges:
    - 203.0.113.0/24
  subnet_ids:
    - /subscriptions/.../subnets/app

security:
  public_access: false
  deletion_protection: true

azure:
  resource_group: production-rg

tags:
  data_classification: critical
```

## Usage

```hcl
module "key_vault" {
  source = "./azure/security/key-vault"
  config_file = "key-vault.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Key Vault ID |
| `key_vault_uri` | Key Vault URI |
| `secret_ids` | Map of secret IDs |
