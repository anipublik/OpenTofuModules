# Azure Service Bus Module

Production-hardened Service Bus namespace with queues and topics.

## Features

- **Queues** — Point-to-point messaging
- **Topics/Subscriptions** — Pub/sub messaging
- **Zone Redundancy** — High availability
- **Network Rules** — VNet and IP restrictions
- **Dead Lettering** — Failed message handling

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-messaging
  team: platform
  cost_center: eng-001

servicebus:
  sku: Standard
  capacity: 0
  
  queues:
    - name: orders
      max_size_mb: 1024
      default_message_ttl: P14D
      max_delivery_count: 10
      dead_lettering_on_message_expiration: true
  
  topics:
    - name: events
      max_size_mb: 1024
      subscriptions:
        - name: processor
          max_delivery_count: 10

networking:
  subnet_ids:
    - /subscriptions/.../subnets/app
  allowed_ip_ranges:
    - 203.0.113.0/24

security:
  public_access: false

reliability:
  zone_redundant: true

azure:
  resource_group: production-rg

tags:
  application: messaging
```

## Usage

```hcl
module "service_bus" {
  source = "./azure/messaging/service-bus"
  config_file = "service-bus.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Service Bus namespace ID |
| `namespace_name` | Namespace name |
| `queue_ids` | Map of queue IDs |
