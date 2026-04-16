# GCP Secret Manager Module

Production-hardened Secret Manager with replication and IAM.

## Features

- **Automatic Replication** — Multi-region secrets
- **Customer-Managed Encryption** — KMS integration
- **Versioning** — Multiple secret versions
- **IAM Bindings** — Access control

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: app-secrets
  team: platform
  cost_center: eng-001

secrets:
  - name: database-password
    secret_data: "CHANGE_ME"
    kms_key_name: projects/my-project/locations/us-central1/keyRings/secrets/cryptoKeys/secret
  
  - name: api-key
    secret_data: "CHANGE_ME"

iam_bindings:
  - secret_index: 0
    role: roles/secretmanager.secretAccessor
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
module "secret_manager" {
  source = "./gcp/security/secret-manager"
  config_file = "secret-manager.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | First secret ID |
| `secret_ids` | Map of secret IDs |
| `secret_names` | Map of secret names |
