# AWS Lambda Module

Production-hardened Lambda function with VPC support, encryption, and monitoring.

## Features

- **Environment Variable Encryption** — KMS encryption for sensitive data
- **VPC Integration** — Private subnet deployment for database access
- **Dead Letter Queue** — SQS DLQ for failed invocations
- **X-Ray Tracing** — Distributed tracing enabled
- **Reserved Concurrency** — Prevent function from consuming all account concurrency
- **CloudWatch Logs** — Automatic log group creation with retention

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: data-processor
  team: platform
  cost_center: eng-001

function:
  runtime: python3.11
  handler: index.handler
  timeout: 300
  memory_size: 1024
  
  code:
    s3_bucket: lambda-code-bucket
    s3_key: data-processor/v1.0.0.zip
  
  environment_variables:
    DATABASE_URL: "{{secret}}"
    LOG_LEVEL: INFO
  
  reserved_concurrent_executions: 100
  
  dead_letter_config:
    target_arn: arn:aws:sqs:us-east-1:123456789012:lambda-dlq
  
  tracing_mode: Active

networking:
  vpc_config:
    subnet_ids:
      - subnet-11111111
      - subnet-22222222
    security_group_ids:
      - sg-lambda-functions

security:
  encryption_enabled: true
  kms_key_arn: arn:aws:kms:us-east-1:123456789012:key/...

tags:
  application: data-pipeline
```

## Usage

```hcl
module "lambda" {
  source = "./aws/compute/lambda"
  config_file = "lambda-function.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Lambda function name |
| `resource_arn` | Lambda function ARN |
| `function_name` | Lambda function name |
| `invoke_arn` | Lambda invoke ARN |
| `role_arn` | Lambda execution role ARN |
