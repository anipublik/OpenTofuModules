# Datadog Logs Index

Configure log indexes with retention and exclusion filters.

## Features

- **Query-Based Filtering** — Index specific logs
- **Retention Configuration** — Set retention period
- **Daily Limits** — Control indexed volume
- **Exclusion Filters** — Sample or exclude logs

## Usage

```hcl
module "logs_index" {
  source = "./datadog/logs/index"
  config_file = "logs/application-index.yaml"
}
```
