# AWS CloudWatch Alarm Module

Production-hardened CloudWatch alarms with SNS notifications.

## Features

- **Metric Alarms** — Threshold-based alerting
- **Composite Alarms** — Multiple condition alarms
- **Anomaly Detection** — ML-based anomaly alarms
- **SNS Integration** — Multi-channel notifications
- **Alarm Actions** — Auto-scaling, Lambda triggers
- **Missing Data Treatment** — Configurable behavior

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: api-monitoring
  team: platform
  cost_center: eng-001

alarms:
  - name: high-cpu
    description: Alert when CPU exceeds 80%
    comparison_operator: GreaterThanThreshold
    evaluation_periods: 2
    threshold: 80
    metric_name: CPUUtilization
    namespace: AWS/EC2
    period: 300
    statistic: Average
    dimensions:
      AutoScalingGroupName: api-asg
    alarm_actions:
      - arn:aws:sns:us-east-1:123456789012:alerts
    treat_missing_data: notBreaching
  
  - name: high-error-rate
    description: Alert when error rate exceeds 5%
    comparison_operator: GreaterThanThreshold
    evaluation_periods: 1
    threshold: 5
    metric_name: ErrorRate
    namespace: Application
    period: 60
    statistic: Average
    alarm_actions:
      - arn:aws:sns:us-east-1:123456789012:critical-alerts
    treat_missing_data: breaching
  
  - name: low-request-count
    description: Alert when requests drop below 10/min
    comparison_operator: LessThanThreshold
    evaluation_periods: 3
    threshold: 10
    metric_name: RequestCount
    namespace: AWS/ApplicationELB
    period: 60
    statistic: Sum
    alarm_actions:
      - arn:aws:sns:us-east-1:123456789012:alerts

tags:
  application: api
```

## Usage

```hcl
module "alarms" {
  source = "./aws/observability/cloudwatch-alarm"
  config_file = "alarms.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | First alarm ID |
| `resource_arn` | First alarm ARN |
| `alarm_arns` | Map of alarm ARNs |
| `alarm_ids` | Map of alarm IDs |
