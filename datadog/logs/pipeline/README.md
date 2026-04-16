# Datadog Logs Pipeline

Process and enrich logs with parsers and processors.

## Features

- **Grok Parsers** — Parse unstructured logs
- **Date Remappers** — Extract timestamps
- **Attribute Remappers** — Map fields to standard attributes
- **Status Remappers** — Normalize log levels

## Usage

```hcl
module "logs_pipeline" {
  source = "./datadog/logs/pipeline"
  config_file = "logs/json-parser.yaml"
}
```
