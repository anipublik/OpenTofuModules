# GCP Cloud Tasks Module

Production-hardened Cloud Tasks queue with retry policies.

## Features

- **Task Queues** — Asynchronous task execution
- **Retry Policies** — Configurable retries
- **Rate Limiting** — Dispatch rate control
- **Logging** — Stackdriver integration

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: background-jobs
  team: platform
  cost_center: eng-001

queue:
  max_dispatches_per_second: 500
  max_concurrent_dispatches: 1000
  max_burst_size: 100
  
  max_attempts: 100
  max_retry_duration: "0s"
  max_backoff: 3600s
  min_backoff: 0.1s
  max_doublings: 16
  
  enable_logging: true
  log_sampling_ratio: 1.0

gcp:
  project_id: my-project

tags:
  application: task-queue
```

## Usage

```hcl
module "tasks" {
  source = "./gcp/messaging/tasks"
  config_file = "tasks.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Queue ID |
| `queue_name` | Queue name |
