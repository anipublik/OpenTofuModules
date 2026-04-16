# AWS EventBridge Module

Production-hardened EventBridge event bus with rules, targets, and archives.

## Features

- **Custom Event Bus** — Isolated event routing
- **Event Rules** — Pattern matching and scheduling
- **Multiple Targets** — Lambda, SQS, SNS, Step Functions
- **Event Archive** — Replay capability
- **Dead Letter Queue** — Failed event handling
- **Cross-Account Events** — Event bus policies

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: application-events
  team: platform
  cost_center: eng-001

bus:
  policy:
    version: "2012-10-17"
    statements:
      - sid: AllowCrossAccountPutEvents
        effect: Allow
        principals:
          - type: AWS
            identifiers:
              - arn:aws:iam::987654321098:root
        actions:
          - events:PutEvents
        resources:
          - "*"
  
  rules:
    - name: order-created
      description: Route order created events
      enabled: true
      event_pattern:
        source:
          - app.orders
        detail-type:
          - Order Created
      targets:
        - arn: arn:aws:lambda:us-east-1:123456789012:function:process-order
          role_arn: arn:aws:iam::123456789012:role/eventbridge-invoke
          retry_policy:
            maximum_event_age: 86400
            maximum_retry_attempts: 185
          dead_letter_arn: arn:aws:sqs:us-east-1:123456789012:events-dlq
    
    - name: daily-report
      description: Generate daily report
      enabled: true
      schedule_expression: cron(0 8 * * ? *)
      targets:
        - arn: arn:aws:lambda:us-east-1:123456789012:function:generate-report
          role_arn: arn:aws:iam::123456789012:role/eventbridge-invoke
  
  archives:
    - name: order-events-archive
      description: Archive all order events
      retention_days: 30
      event_pattern:
        source:
          - app.orders

tags:
  application: event-driven-app
```

## Usage

```hcl
module "eventbridge" {
  source = "./aws/messaging/eventbridge"
  config_file = "eventbridge.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | EventBridge bus ID |
| `resource_arn` | EventBridge bus ARN |
| `event_bus_name` | EventBridge bus name |
| `event_bus_arn` | EventBridge bus ARN |
| `rule_arns` | Map of rule ARNs |
