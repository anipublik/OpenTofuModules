# AWS IAM Role Module

Production-hardened IAM role with least-privilege policies and trust relationships.

## Features

- **Least Privilege** — Minimal required permissions
- **Trust Policies** — Service and federated principals
- **Managed Policies** — AWS and customer-managed policies
- **Inline Policies** — Role-specific policies
- **Session Duration** — Configurable max session duration
- **Permission Boundaries** — Delegated administration support

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: lambda-execution
  team: platform
  cost_center: eng-001

role:
  description: Execution role for Lambda functions
  max_session_duration: 3600
  
  assume_role_policy:
    version: "2012-10-17"
    statements:
      - effect: Allow
        principals:
          - type: Service
            identifiers:
              - lambda.amazonaws.com
        actions:
          - sts:AssumeRole
  
  managed_policy_arns:
    - arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole
  
  inline_policies:
    - name: s3-access
      policy:
        version: "2012-10-17"
        statements:
          - effect: Allow
            actions:
              - s3:GetObject
              - s3:PutObject
            resources:
              - arn:aws:s3:::my-bucket/*
  
  permissions_boundary: arn:aws:iam::123456789012:policy/DeveloperBoundary

tags:
  application: data-pipeline
```

## Usage

```hcl
module "iam_role" {
  source = "./aws/security/iam-role"
  config_file = "iam-role.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | IAM role ID |
| `resource_arn` | IAM role ARN |
| `role_arn` | IAM role ARN |
| `role_name` | IAM role name |
| `role_unique_id` | IAM role unique ID |
