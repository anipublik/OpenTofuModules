# Datadog Screenboard

Free-form dashboards with flexible widget positioning.

## Features

- **Flexible Layout** — Position widgets anywhere
- **Custom Sizing** — Adjust widget dimensions
- **Note Widgets** — Add documentation and context
- **Image Widgets** — Embed images and diagrams

## Usage

```hcl
module "screenboard" {
  source = "./datadog/dashboards/screenboard"
  config_file = "dashboards/infrastructure.yaml"
}
```
