# GCP IAM Module

Production-hardened IAM with service accounts and custom roles.

## Features

- **Service Accounts** — Application identities
- **Custom Roles** — Fine-grained permissions
- **IAM Bindings** — Project-level access
- **Service Account Keys** — Authentication keys

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: app-iam
  team: platform
  cost_center: eng-001

iam:
  service_accounts:
    - account_id: app-backend
      display_name: Application Backend Service Account
      description: Service account for backend services
      create_key: false
  
  custom_roles:
    - role_id: customStorageReader
      title: Custom Storage Reader
      description: Read-only access to specific buckets
      permissions:
        - storage.buckets.get
        - storage.objects.get
        - storage.objects.list
      stage: GA
  
  project_iam_bindings:
    - role: roles/storage.objectViewer
      member: serviceAccount:app-backend@my-project.iam.gserviceaccount.com

gcp:
  project_id: my-project

tags:
  iam_tier: application
```

## Usage

```hcl
module "iam" {
  source = "./gcp/security/iam"
  config_file = "iam.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | First service account ID |
| `service_account_emails` | Map of service account emails |
| `service_account_ids` | Map of service account IDs |
