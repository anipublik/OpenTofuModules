# AWS Secrets Manager Module

Production-hardened Secrets Manager secret with automatic rotation and KMS encryption.

## Features

- **KMS Encryption** — Customer-managed key encryption
- **Automatic Rotation** — Lambda-based rotation
- **Version Management** — Multiple secret versions
- **Recovery Window** — 30-day deletion protection
- **Cross-Region Replication** — Multi-region secrets
- **Resource Policies** — Fine-grained access control

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: database-password
  team: platform
  cost_center: eng-001

secret:
  description: RDS database master password
  kms_key_id: arn:aws:kms:us-east-1:123456789012:key/...
  
  secret_string: |
    {
      "username": "dbadmin",
      "password": "CHANGE_ME",
      "engine": "postgres",
      "host": "db.example.com",
      "port": 5432,
      "dbname": "production"
    }
  
  rotation:
    enabled: true
    rotation_lambda_arn: arn:aws:lambda:us-east-1:123456789012:function:rotate-secret
    rotation_days: 30
  
  recovery_window_in_days: 30
  
  replica_regions:
    - us-west-2

security:
  encryption_enabled: true

tags:
  data_classification: critical
```

## Usage

```hcl
module "secret" {
  source = "./aws/security/secrets-manager"
  config_file = "secret.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Secret ID |
| `resource_arn` | Secret ARN |
| `secret_arn` | Secret ARN |
| `secret_version_id` | Current version ID |
