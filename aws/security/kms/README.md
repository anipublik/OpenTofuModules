# AWS KMS Module

Production-hardened KMS key with automatic rotation and key policies.

## Features

- **Automatic Rotation** — Annual key rotation enabled
- **Key Policies** — Least-privilege access control
- **Multi-Region Keys** — Cross-region replication support
- **Deletion Protection** — 30-day waiting period
- **CloudTrail Integration** — All key usage logged
- **Alias Support** — Human-readable key names

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: data-encryption
  team: platform
  cost_center: eng-001

key:
  description: Encryption key for application data
  key_usage: ENCRYPT_DECRYPT
  customer_master_key_spec: SYMMETRIC_DEFAULT
  
  enable_key_rotation: true
  deletion_window_in_days: 30
  
  policy:
    statements:
      - sid: Enable IAM User Permissions
        effect: Allow
        principals:
          - type: AWS
            identifiers:
              - arn:aws:iam::123456789012:root
        actions:
          - kms:*
        resources:
          - "*"
      
      - sid: Allow services to use the key
        effect: Allow
        principals:
          - type: Service
            identifiers:
              - s3.amazonaws.com
              - rds.amazonaws.com
        actions:
          - kms:Decrypt
          - kms:GenerateDataKey
        resources:
          - "*"
  
  aliases:
    - alias/app-data-key

tags:
  data_classification: sensitive
```

## Usage

```hcl
module "kms" {
  source = "./aws/security/kms"
  config_file = "kms-key.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | KMS key ID |
| `resource_arn` | KMS key ARN |
| `key_id` | KMS key ID |
| `key_arn` | KMS key ARN |
