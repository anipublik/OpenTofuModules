# GCP Audit Logs Module

Production-hardened Cloud Audit Logs configuration.

## Features

- **Admin Activity** — Administrative actions
- **Data Access** — Data read/write operations
- **System Events** — GCP-initiated events
- **Exemptions** — Exclude specific members

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: audit-config
  team: platform
  cost_center: eng-001

audit:
  services:
    - allServices
    - storage.googleapis.com
    - compute.googleapis.com
  
  log_types:
    - ADMIN_READ
    - DATA_READ
    - DATA_WRITE
  
  exempted_members:
    - serviceAccount:monitoring@my-project.iam.gserviceaccount.com

gcp:
  project_id: my-project

tags:
  compliance: required
```

## Usage

```hcl
module "audit_logs" {
  source = "./gcp/observability/audit-logs"
  config_file = "audit-logs.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | First audit config ID |
| `audit_config_ids` | Map of audit config IDs |
