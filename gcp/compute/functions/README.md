# GCP Cloud Functions Module

Production-hardened Cloud Functions with VPC connector and secrets.

## Features

- **Gen 2** — Cloud Run-based functions
- **VPC Connector** — Private networking
- **Secrets** — Secret Manager integration
- **Auto-scaling** — Min/max instances
- **Event Triggers** — Pub/Sub, Storage, HTTP

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: data-processor
  team: platform
  cost_center: eng-001

function:
  runtime: python311
  entry_point: process_data
  source_bucket: function-code-bucket
  source_object: processor/v1.0.0.zip
  
  memory: 512M
  timeout: 300
  min_instances: 1
  max_instances: 100
  
  environment_variables:
    ENV: production
  
  secret_environment_variables:
    - key: DATABASE_PASSWORD
      secret: db-password
      version: latest
  
  event_trigger:
    event_type: google.cloud.pubsub.topic.v1.messagePublished
    pubsub_topic: projects/my-project/topics/data-events
    retry_policy: RETRY_POLICY_RETRY

networking:
  vpc_connector: projects/my-project/locations/us-central1/connectors/main

security:
  public_access: false

gcp:
  project_id: my-project

tags:
  application: data-pipeline
```

## Usage

```hcl
module "functions" {
  source = "./gcp/compute/functions"
  config_file = "functions.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Function ID |
| `function_uri` | Function URI |
| `function_url` | Function URL |
