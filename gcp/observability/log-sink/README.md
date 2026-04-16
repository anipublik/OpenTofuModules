# GCP Log Sink Module

Production-hardened Cloud Logging sinks for log export.

## Features

- **Log Sinks** — Export to BigQuery, Storage, Pub/Sub
- **Filters** — Selective log export
- **Exclusions** — Exclude specific logs
- **Organization Sinks** — Organization-level export

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: log-export
  team: platform
  cost_center: eng-001

sinks:
  - name: bigquery-sink
    destination: bigquery.googleapis.com/projects/my-project/datasets/logs
    filter: |
      resource.type="gce_instance"
      severity>=ERROR
    unique_writer_identity: true
    use_partitioned_tables: true
    exclusions:
      - name: exclude-health-checks
        filter: 'httpRequest.requestUrl=~"/health"'
        disabled: false
  
  - name: storage-sink
    destination: storage.googleapis.com/log-archive-bucket
    filter: 'severity>=WARNING'

gcp:
  project_id: my-project

tags:
  logging: enabled
```

## Usage

```hcl
module "log_sink" {
  source = "./gcp/observability/log-sink"
  config_file = "log-sink.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | First sink ID |
| `sink_ids` | Map of sink IDs |
| `writer_identities` | Map of writer identities |
