# Datadog Logs Archive

Archive logs to S3, GCS, or Azure Blob for long-term storage.

## Features

- **Multi-Cloud Support** — S3, GCS, Azure Blob
- **Query-Based Filtering** — Archive specific logs
- **Rehydration** — Restore logs for analysis
- **Tag Inclusion** — Preserve tags in archives

## Usage

```hcl
module "logs_archive" {
  source = "./datadog/logs/archive"
  config_file = "logs/compliance-archive.yaml"
}
```
