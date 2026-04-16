# Datadog AWS Integration

Integrate Datadog with AWS CloudWatch for metrics and logs.

## Features

- **IAM Role Authentication** — Secure role-based access
- **Namespace Filtering** — Select specific AWS services
- **Tag-Based Filtering** — Filter by resource tags
- **Region Exclusion** — Exclude specific regions

## Usage

```hcl
module "aws_integration" {
  source = "./datadog/integrations/aws"
  config_file = "integrations/aws.yaml"
}
```

## Setup

1. Create IAM role with Datadog trust policy
2. Attach required policies
3. Configure integration with role ARN
