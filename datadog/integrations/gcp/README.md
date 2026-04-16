# Datadog GCP Integration

Integrate Datadog with GCP Stackdriver.

## Features

- **Service Account Auth** — Secure authentication
- **Project-Level Monitoring** — Monitor entire projects
- **Host Filtering** — Filter by labels
- **Automute** — Mute during maintenance

## Usage

```hcl
module "gcp_integration" {
  source = "./datadog/integrations/gcp"
  config_file = "integrations/gcp.yaml"
}
```
