# Datadog Modules

Production-hardened Datadog monitoring, alerting, and observability modules.

## Overview

YAML-driven Datadog resources for comprehensive monitoring and observability across your infrastructure, applications, and logs.

## Module Categories

### [Monitors](./monitors/README.md)

Create alerts for APM, infrastructure, logs, and custom metrics with notification routing and escalation policies.

- **[APM Monitor](./monitors/apm/README.md)** — Application performance monitoring alerts
- **[Infrastructure Monitor](./monitors/infrastructure/README.md)** — Host and container monitoring
- **[Logs Monitor](./monitors/logs/README.md)** — Log-based alerting
- **[Custom Monitor](./monitors/custom/README.md)** — Custom metric monitors
- **[Composite Monitor](./monitors/composite/README.md)** — Multi-condition composite alerts

### [Dashboards](./dashboards/README.md)

Build visual dashboards for metrics, traces, and logs with customizable widgets and layouts.

- **[Timeboard](./dashboards/timeboard/README.md)** — Time-synchronized metric dashboards
- **[Screenboard](./dashboards/screenboard/README.md)** — Flexible layout dashboards

### [Synthetics](./synthetics/README.md)

Monitor API endpoints and browser workflows with automated testing and alerting.

- **[API Test](./synthetics/api-test/README.md)** — HTTP/HTTPS endpoint monitoring
- **[Browser Test](./synthetics/browser-test/README.md)** — Browser-based user journey testing

### [Logs](./logs/README.md)

Process, index, and archive logs with pipelines, processors, and retention policies.

- **[Pipeline](./logs/pipeline/README.md)** — Log processing pipelines with processors
- **[Index](./logs/index/README.md)** — Log indexes with retention and exclusion filters
- **[Archive](./logs/archive/README.md)** — Long-term log storage to S3/GCS/Azure Blob

### [Integrations](./integrations/README.md)

Connect Datadog with cloud providers and third-party services for unified monitoring.

- **[AWS Integration](./integrations/aws/README.md)** — AWS CloudWatch metrics and logs
- **[Azure Integration](./integrations/azure/README.md)** — Azure Monitor integration
- **[GCP Integration](./integrations/gcp/README.md)** — GCP Stackdriver integration
- **[Slack Integration](./integrations/slack/README.md)** — Slack notifications
- **[PagerDuty Integration](./integrations/pagerduty/README.md)** — PagerDuty incident management

### [SLO](./slo/README.md)

Define and track Service Level Objectives with error budgets and burn rate alerts.

- **[Metric SLO](./slo/metric/README.md)** — Metric-based SLO tracking
- **[Monitor SLO](./slo/monitor/README.md)** — Monitor-based SLO tracking

## Quick Start

```hcl
# Configure Datadog provider
terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.com"  # or datadoghq.eu
}

# Create APM monitor
module "api_latency_monitor" {
  source = "./datadog/monitors/apm"
  config_file = "monitors/api-latency.yaml"
}

# Create dashboard
module "service_dashboard" {
  source = "./datadog/dashboards/timeboard"
  config_file = "dashboards/service-overview.yaml"
}

# Create SLO
module "api_availability_slo" {
  source = "./datadog/slo/metric"
  config_file = "slo/api-availability.yaml"
}
```

## Configuration

All modules use YAML configuration files:

```yaml
meta:
  environment: production
  name: api-latency
  team: backend
  cost_center: eng-001

datadog:
  api_key: ${DD_API_KEY}
  app_key: ${DD_APP_KEY}

monitor:
  type: metric alert
  query: "avg(last_5m):avg:trace.http.request.duration{service:api,env:production} > 1"
  message: |
    API latency is high
    @slack-backend-alerts
  
  thresholds:
    critical: 1.0
    warning: 0.5

tags:
  - service:api
  - team:backend
  - severity:high
```

## Features

- **YAML-Driven** — No HCL knowledge required
- **Consistent Tagging** — Automatic tagging across all resources
- **Alert Routing** — Notification channels with escalation
- **SLO Tracking** — Error budgets and burn rate monitoring
- **Multi-Environment** — Dev, staging, production support
- **Integration Ready** — Connect with AWS, Azure, GCP, Slack, PagerDuty

## Authentication

Set Datadog credentials as environment variables:

```bash
export DD_API_KEY="your-api-key"
export DD_APP_KEY="your-app-key"
export DD_SITE="datadoghq.com"  # or datadoghq.eu
```

Or use YAML configuration:

```yaml
datadog:
  api_key: ${DD_API_KEY}
  app_key: ${DD_APP_KEY}
  site: datadoghq.com
```

## Best Practices

- **Tag Everything** — Use consistent tags for filtering and grouping
- **Alert Fatigue** — Set appropriate thresholds to avoid noise
- **SLO-Based Alerting** — Alert on error budget burn rate, not individual metrics
- **Composite Monitors** — Combine multiple conditions to reduce false positives
- **Notification Routing** — Route alerts to appropriate teams and channels
- **Dashboard Standardization** — Use consistent layouts and widgets across teams

## Cost Optimization

- **Log Sampling** — Use exclusion filters to reduce indexed log volume
- **Custom Metrics** — Monitor custom metric usage to avoid overages
- **Synthetic Test Frequency** — Adjust test frequency based on criticality
- **Log Archives** — Archive old logs to S3/GCS for compliance
- **Host Tagging** — Proper tagging enables accurate cost allocation

## Additional Resources

- [Datadog Documentation](https://docs.datadoghq.com/)
- [Terraform Provider](https://registry.terraform.io/providers/DataDog/datadog/latest/docs)
- [Best Practices](https://docs.datadoghq.com/monitors/guide/best-practices/)
