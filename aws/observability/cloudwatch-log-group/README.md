# AWS CloudWatch Log Group Module

Production-hardened CloudWatch log group with encryption and retention.

## Features

- **KMS Encryption** — Log data encryption at rest
- **Retention Policies** — Configurable retention period
- **Metric Filters** — Extract metrics from logs
- **Subscription Filters** — Stream logs to other services
- **Log Insights** — Query and analyze logs

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: application-logs
  team: platform
  cost_center: eng-001

log_group:
  retention_in_days: 30
  kms_key_id: arn:aws:kms:us-east-1:123456789012:key/...
  
  metric_filters:
    - name: error-count
      pattern: "[ERROR]"
      metric_transformation:
        namespace: Application
        name: ErrorCount
        value: "1"
        default_value: "0"
    
    - name: response-time
      pattern: "[time, request_id, duration]"
      metric_transformation:
        namespace: Application
        name: ResponseTime
        value: "$duration"
  
  subscription_filters:
    - name: elasticsearch-stream
      destination_arn: arn:aws:lambda:us-east-1:123456789012:function:log-to-es
      filter_pattern: ""

security:
  encryption_enabled: true

tags:
  application: web-app
```

## Usage

```hcl
module "log_group" {
  source = "./aws/observability/cloudwatch-log-group"
  config_file = "log-group.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Log group ID |
| `resource_arn` | Log group ARN |
| `log_group_name` | Log group name |
| `log_group_arn` | Log group ARN |
