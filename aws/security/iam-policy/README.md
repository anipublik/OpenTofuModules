# AWS IAM Policy Module

Production-hardened IAM policy with least-privilege permissions.

## Features

- **Least Privilege** — Minimal required permissions
- **Resource-Level Permissions** — Specific resource ARNs
- **Condition Keys** — Context-based access control
- **Policy Validation** — Syntax and logic validation
- **Version Management** — Policy versioning support

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: s3-read-only
  team: platform
  cost_center: eng-001

policy:
  description: Read-only access to specific S3 buckets
  
  policy_document:
    version: "2012-10-17"
    statements:
      - sid: ListBuckets
        effect: Allow
        actions:
          - s3:ListBucket
          - s3:GetBucketLocation
        resources:
          - arn:aws:s3:::my-data-bucket
        conditions:
          - test: StringEquals
            variable: s3:prefix
            values:
              - data/
      
      - sid: GetObjects
        effect: Allow
        actions:
          - s3:GetObject
          - s3:GetObjectVersion
        resources:
          - arn:aws:s3:::my-data-bucket/data/*

tags:
  policy_type: data-access
```

## Usage

```hcl
module "iam_policy" {
  source = "./aws/security/iam-policy"
  config_file = "iam-policy.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | IAM policy ID |
| `resource_arn` | IAM policy ARN |
| `policy_arn` | IAM policy ARN |
| `policy_name` | IAM policy name |
