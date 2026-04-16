# Datadog Infrastructure Monitor

Monitor host and container metrics including CPU, memory, disk, and network.

## Features

- **System Metrics** — CPU, memory, disk, network monitoring
- **Process Monitoring** — Track specific processes
- **Container Metrics** — Docker and Kubernetes monitoring
- **Multi-Alert** — Alert by host, container, or custom tags
- **No Data Detection** — Alert when hosts stop reporting

## Usage

```hcl
module "infrastructure_monitor" {
  source = "./datadog/monitors/infrastructure"
  config_file = "monitors/high-cpu.yaml"
}
```

## Common Queries

**High CPU:**
```yaml
query: "avg(last_5m):avg:system.cpu.user{env:production} by {host} > 90"
```

**Low Memory:**
```yaml
query: "avg(last_5m):avg:system.mem.pct_usable{*} by {host} < 10"
```

**High Disk Usage:**
```yaml
query: "avg(last_5m):avg:system.disk.in_use{*} by {host,device} > 90"
```
