# Azure Event Grid Module

Production-hardened Event Grid topic with subscriptions.

## Features

- **Custom Topics** — Event publishing
- **Event Subscriptions** — Multiple handlers
- **Event Filtering** — Subject-based filtering
- **Retry Policies** — Delivery guarantees
- **Dead Lettering** — Failed event handling

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-events
  team: platform
  cost_center: eng-001

topic:
  input_schema: EventGridSchema
  
  subscriptions:
    - name: webhook-handler
      webhook_endpoint:
        url: https://api.example.com/events
      subject_filter:
        subject_begins_with: /orders/
      included_event_types:
        - OrderCreated
        - OrderUpdated
      max_delivery_attempts: 30
      event_time_to_live: 1440

security:
  public_access: false

azure:
  resource_group: production-rg

tags:
  application: event-driven
```

## Usage

```hcl
module "event_grid" {
  source = "./azure/messaging/event-grid"
  config_file = "event-grid.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Event Grid topic ID |
| `topic_endpoint` | Topic endpoint |
