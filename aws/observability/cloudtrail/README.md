# AWS CloudTrail Module

Production-hardened CloudTrail with encryption, log validation, and multi-region support.

## Features

- **Multi-Region** — Capture events from all regions
- **Log File Validation** — Integrity verification
- **KMS Encryption** — Log file encryption
- **S3 Lifecycle** — Automated log archival
- **CloudWatch Logs** — Real-time log analysis
- **Event Selectors** — Data and management events

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: organization-trail
  team: platform
  cost_center: eng-001

trail:
  is_multi_region_trail: true
  is_organization_trail: false
  include_global_service_events: true
  enable_log_file_validation: true
  
  s3_bucket_name: cloudtrail-logs-bucket
  s3_key_prefix: cloudtrail/
  
  kms_key_id: arn:aws:kms:us-east-1:123456789012:key/...
  
  cloudwatch_logs:
    enabled: true
    log_group_name: /aws/cloudtrail/organization
    role_arn: arn:aws:iam::123456789012:role/cloudtrail-cloudwatch
  
  event_selectors:
    - read_write_type: All
      include_management_events: true
      data_resources:
        - type: AWS::S3::Object
          values:
            - arn:aws:s3:::sensitive-bucket/*
        - type: AWS::Lambda::Function
          values:
            - arn:aws:lambda:*:123456789012:function/*
  
  insight_selectors:
    - insight_type: ApiCallRateInsight

security:
  encryption_enabled: true
  audit_logging: true

tags:
  compliance: required
```

## Usage

```hcl
module "cloudtrail" {
  source = "./aws/observability/cloudtrail"
  config_file = "cloudtrail.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | CloudTrail ID |
| `resource_arn` | CloudTrail ARN |
| `trail_arn` | CloudTrail ARN |
| `trail_id` | CloudTrail ID |
| `home_region` | CloudTrail home region |
