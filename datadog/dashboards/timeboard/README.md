# Datadog Timeboard

Time-synchronized dashboards with ordered widget layout.

## Features

- **Time Synchronization** — All widgets share same time range
- **Ordered Layout** — Vertical widget stacking
- **Template Variables** — Dynamic filtering
- **Multiple Widget Types** — Timeseries, query value, heatmap

## Usage

```hcl
module "timeboard" {
  source = "./datadog/dashboards/timeboard"
  config_file = "dashboards/service-overview.yaml"
}
```
