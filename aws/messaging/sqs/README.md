# AWS SQS Module

Production-hardened SQS queue with encryption, dead-letter queue, and FIFO support.

## Features

- **KMS Encryption** — Server-side encryption
- **Dead Letter Queue** — Failed message handling
- **FIFO Support** — Ordered message delivery
- **Message Retention** — Up to 14 days
- **Visibility Timeout** — Configurable processing time
- **Long Polling** — Reduced empty receives

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: order-processing
  team: platform
  cost_center: eng-001

queue:
  fifo: false
  content_based_deduplication: false
  
  delay_seconds: 0
  max_message_size: 262144
  message_retention_seconds: 345600  # 4 days
  receive_wait_time_seconds: 20  # Long polling
  visibility_timeout_seconds: 300
  
  dead_letter_queue:
    max_receive_count: 5
    message_retention_seconds: 1209600  # 14 days
  
  policy:
    version: "2012-10-17"
    statements:
      - sid: AllowSNSPublish
        effect: Allow
        principals:
          - type: Service
            identifiers:
              - sns.amazonaws.com
        actions:
          - sqs:SendMessage
        resources:
          - "*"
        conditions:
          - test: ArnEquals
            variable: aws:SourceArn
            values:
              - arn:aws:sns:us-east-1:123456789012:my-topic

security:
  encryption_enabled: true

tags:
  application: order-system
```

## Usage

```hcl
module "sqs" {
  source = "./aws/messaging/sqs"
  config_file = "sqs-queue.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | SQS queue ID |
| `resource_arn` | SQS queue ARN |
| `queue_url` | SQS queue URL |
| `queue_arn` | SQS queue ARN |
| `dlq_url` | Dead letter queue URL |
| `dlq_arn` | Dead letter queue ARN |
