# Azure Event Hub Module

Production-hardened Event Hub namespace with hubs and consumer groups.

## Features

- **Event Hubs** — Streaming ingestion
- **Capture** — Automatic archival to Storage
- **Consumer Groups** — Multiple readers
- **Zone Redundancy** — High availability
- **Auto-inflate** — Automatic throughput scaling

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: telemetry
  team: platform
  cost_center: eng-001

eventhub:
  sku: Standard
  capacity: 1
  auto_inflate_enabled: true
  maximum_throughput_units: 10
  
  hubs:
    - name: metrics
      partition_count: 4
      message_retention: 7
      capture_enabled: true
      capture_interval: 300
      capture_size_limit: 314572800
      capture_container: eventhub-capture
      capture_storage_account_id: /subscriptions/.../storageAccounts/storage
      consumer_groups:
        - analytics
        - monitoring

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
  application: telemetry
```

## Usage

```hcl
module "event_hub" {
  source = "./azure/messaging/event-hub"
  config_file = "event-hub.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Event Hub namespace ID |
| `namespace_name` | Namespace name |
| `eventhub_ids` | Map of Event Hub IDs |
