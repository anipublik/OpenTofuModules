# AWS SNS Module

Production-hardened SNS topic with encryption, subscriptions, and delivery policies.

## Features

- **KMS Encryption** — Message encryption at rest
- **FIFO Support** — Ordered message delivery
- **Multiple Subscriptions** — SQS, Lambda, HTTP, email
- **Delivery Policies** — Retry and backoff configuration
- **Message Filtering** — Subscription filter policies
- **Dead Letter Queue** — Failed delivery handling

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: order-events
  team: platform
  cost_center: eng-001

topic:
  display_name: Order Events Topic
  fifo: false
  content_based_deduplication: false
  
  delivery_policy:
    http:
      defaultHealthyRetryPolicy:
        minDelayTarget: 20
        maxDelayTarget: 20
        numRetries: 3
        numMaxDelayRetries: 0
        numNoDelayRetries: 0
        numMinDelayRetries: 0
        backoffFunction: linear
  
  subscriptions:
    - protocol: sqs
      endpoint: arn:aws:sqs:us-east-1:123456789012:order-queue
      raw_message_delivery: true
      filter_policy:
        event_type:
          - order_created
          - order_updated
    
    - protocol: lambda
      endpoint: arn:aws:lambda:us-east-1:123456789012:function:process-order
      filter_policy:
        event_type:
          - order_completed
    
    - protocol: email
      endpoint: alerts@example.com
      filter_policy:
        priority:
          - high

security:
  encryption_enabled: true

tags:
  application: order-system
```

## Usage

```hcl
module "sns" {
  source = "./aws/messaging/sns"
  config_file = "sns-topic.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | SNS topic ID |
| `resource_arn` | SNS topic ARN |
| `topic_arn` | SNS topic ARN |
| `topic_id` | SNS topic ID |
