# Azure Managed Identity Module

Production-hardened User-Assigned Managed Identity with role assignments.

## Features

- **User-Assigned Identity** — Reusable identity
- **Role Assignments** — RBAC permissions
- **Multi-Resource** — Shared across resources

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-identity
  team: platform
  cost_center: eng-001

identity:
  role_assignments:
    - scope: /subscriptions/.../resourceGroups/production-rg
      role_definition_name: Contributor
    
    - scope: /subscriptions/.../providers/Microsoft.Storage/storageAccounts/storage
      role_definition_name: Storage Blob Data Contributor

azure:
  resource_group: production-rg

tags:
  application: web-app
```

## Usage

```hcl
module "managed_identity" {
  source = "./azure/security/managed-identity"
  config_file = "managed-identity.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Managed identity ID |
| `principal_id` | Principal ID |
| `client_id` | Client ID |
