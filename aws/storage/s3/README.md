# AWS S3 Module

Production-hardened S3 bucket with encryption, versioning, and lifecycle policies.

## Features

- **Encryption at Rest** — AES-256 or KMS encryption enabled by default
- **Versioning** — Object versioning enabled for data protection
- **Public Access Block** — All public access blocked by default
- **Lifecycle Policies** — Automated tiering and expiration rules
- **Replication** — Cross-region replication support
- **Access Logging** — Server access logging to separate bucket
- **Object Lock** — WORM compliance mode support

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: data-bucket
  team: platform
  cost_center: eng-001

bucket:
  versioning: true
  force_destroy: false
  
  lifecycle_rules:
    - name: archive-old-versions
      enabled: true
      noncurrent_version_transition:
        days: 30
        storage_class: STANDARD_IA
      noncurrent_version_expiration:
        days: 90
    
    - name: intelligent-tiering
      enabled: true
      transition:
        days: 0
        storage_class: INTELLIGENT_TIERING

  replication:
    enabled: false
    destination_bucket: arn:aws:s3:::backup-bucket
    destination_region: us-west-2
  
  logging:
    enabled: true
    target_bucket: logs-bucket
    target_prefix: s3-access-logs/

security:
  encryption_enabled: true
  kms_key_id: null  # Uses AES-256 if null
  public_access: false
  deletion_protection: true

tags:
  data_classification: confidential
```

## Usage

```hcl
module "s3" {
  source = "./aws/storage/s3"
  config_file = "s3-bucket.yaml"
}

output "bucket_name" {
  value = module.s3.resource_name
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | S3 bucket name |
| `resource_arn` | S3 bucket ARN |
| `resource_name` | S3 bucket name |
| `resource_region` | S3 bucket region |
| `bucket_domain_name` | S3 bucket domain name |
| `bucket_regional_domain_name` | S3 bucket regional domain name |
