# GCP Pub/Sub Module

Production-hardened Pub/Sub topic with subscriptions, dead letter queues, and retry policies.

## Features

- **Message Retention** — Retain undelivered messages up to 7 days
- **Dead Letter Queues** — Automatic routing of failed messages
- **Retry Policies** — Exponential backoff for message delivery
- **Message Ordering** — Ordered message delivery per ordering key
- **Regional Storage** — Control message persistence regions
- **IAM Access Control** — Fine-grained topic and subscription permissions
- **Push and Pull** — Support for both push and pull subscriptions
- **Ack Deadlines** — Configurable acknowledgment timeouts

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: order-events
  team: backend
  cost_center: eng-002

gcp:
  project_id: my-gcp-project

topic:
  message_retention_duration: 604800s  # 7 days (max)
  
  allowed_persistence_regions:         # Optional: restrict storage regions
    - us-central1
    - us-east1
  
  iam_bindings:
    - role: roles/pubsub.publisher
      members:
        - serviceAccount:order-service@my-project.iam.gserviceaccount.com
    
    - role: roles/pubsub.viewer
      members:
        - group:backend-team@example.com
  
  subscriptions:
    - name: order-processor
      ack_deadline_seconds: 60
      message_retention_duration: 604800s
      retain_acked_messages: false
      enable_message_ordering: true
      expiration_ttl: ""               # Empty = never expire
      
      dead_letter_topic: projects/my-project/topics/order-events-dlq
      max_delivery_attempts: 5
      
      retry_policy:
        minimum_backoff: 10s
        maximum_backoff: 600s
    
    - name: order-analytics
      ack_deadline_seconds: 30
      message_retention_duration: 86400s
      enable_message_ordering: false

tags:
  project: backend
  compliance: pci-dss
```

## Usage

```hcl
module "pubsub" {
  source = "./gcp/messaging/pubsub"
  config_file = "pubsub.yaml"
}

output "topic_id" {
  value = module.pubsub.topic_id
}

output "subscription_ids" {
  value = module.pubsub.subscription_ids
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `topic_id` | Pub/Sub topic ID |
| `topic_name` | Pub/Sub topic name |
| `subscription_ids` | Map of subscription names to IDs |
| `subscription_names` | List of subscription names |

## Publishing Messages

### Using gcloud

```bash
gcloud pubsub topics publish order-events-production \
  --message='{"order_id": "12345", "status": "completed"}' \
  --attribute=source=api,version=v1
```

### Using Python

```python
from google.cloud import pubsub_v1

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path('my-project', 'order-events-production')

data = b'{"order_id": "12345", "status": "completed"}'
future = publisher.publish(topic_path, data, source='api', version='v1')
message_id = future.result()
```

### With Message Ordering

```python
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path('my-project', 'order-events-production')

# Messages with same ordering_key are delivered in order
future = publisher.publish(
    topic_path,
    b'Message 1',
    ordering_key='order-12345'
)
```

## Consuming Messages

### Pull Subscription (Python)

```python
from google.cloud import pubsub_v1

subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(
    'my-project',
    'order-processor'
)

def callback(message):
    print(f"Received: {message.data}")
    message.ack()

streaming_pull_future = subscriber.subscribe(
    subscription_path,
    callback=callback
)

try:
    streaming_pull_future.result()
except KeyboardInterrupt:
    streaming_pull_future.cancel()
```

### Pull Subscription (gcloud)

```bash
gcloud pubsub subscriptions pull order-processor \
  --auto-ack \
  --limit=10
```

## Dead Letter Queues

Configure DLQ to handle messages that fail repeatedly:

1. Create DLQ topic:
```yaml
# dlq-topic.yaml
meta:
  environment: production
  region: us-central1
  name: order-events-dlq
  team: backend
  cost_center: eng-002

gcp:
  project_id: my-gcp-project

topic:
  message_retention_duration: 604800s
  
  subscriptions:
    - name: dlq-processor
      ack_deadline_seconds: 600      # Longer timeout for manual review
```

2. Reference in main subscription:
```yaml
subscriptions:
  - name: order-processor
    dead_letter_topic: projects/my-project/topics/order-events-dlq-production
    max_delivery_attempts: 5
```

## Message Ordering

Enable ordered delivery per ordering key:

```yaml
subscriptions:
  - name: order-processor
    enable_message_ordering: true
```

**Important:**
- Messages with same `ordering_key` are delivered in order
- Messages with different keys may be delivered out of order
- Ordering is per subscription, not per topic

## Retry Policies

Configure exponential backoff for failed deliveries:

```yaml
subscriptions:
  - name: order-processor
    retry_policy:
      minimum_backoff: 10s           # Initial retry delay
      maximum_backoff: 600s          # Max retry delay (10 minutes)
```

Backoff calculation:
- Retry 1: 10s
- Retry 2: 20s
- Retry 3: 40s
- Retry 4: 80s
- Retry 5: 160s
- Retry 6+: 600s (capped)

## IAM Roles

Common roles for Pub/Sub:

- `roles/pubsub.publisher` — Publish messages to topic
- `roles/pubsub.subscriber` — Pull messages from subscription
- `roles/pubsub.viewer` — View topic and subscription metadata
- `roles/pubsub.editor` — Create/modify topics and subscriptions
- `roles/pubsub.admin` — Full control over Pub/Sub resources

## Security Considerations

- **IAM-Based Access** — Use service accounts with least privilege
- **Regional Storage** — Restrict message persistence to compliant regions
- **Message Encryption** — Messages encrypted at rest by default
- **VPC Service Controls** — Restrict Pub/Sub access to specific VPCs
- **Audit Logging** — Enable Cloud Audit Logs for compliance

## Cost Optimization

- **Message Retention** — Reduce retention duration to minimize storage costs
- **Subscription Expiration** — Set `expiration_ttl` to auto-delete unused subscriptions
- **Batch Publishing** — Publish messages in batches to reduce API calls
- **Ack Deadline** — Set appropriate timeout to avoid unnecessary redeliveries
- **Regional Topics** — Use regional topics instead of multi-regional for lower costs

## Monitoring and Alerting

Key metrics to monitor:

- **Oldest Unacked Message Age** — Indicates processing lag
- **Unacked Message Count** — Backlog size
- **Dead Letter Message Count** — Failed message rate
- **Publish Request Count** — Throughput
- **Subscription Ack Latency** — Processing time

Create alerts:
```bash
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Pub/Sub Backlog Alert" \
  --condition-display-name="High backlog" \
  --condition-threshold-value=1000 \
  --condition-threshold-duration=300s
```

## Troubleshooting

**Messages not being delivered:**
- Verify subscription exists and is active
- Check IAM permissions for subscriber
- Ensure ack deadline is sufficient for processing
- Review dead letter queue for failed messages

**High message latency:**
- Increase number of subscriber instances
- Optimize message processing code
- Check for network connectivity issues
- Consider using streaming pull instead of synchronous pull

**Messages delivered multiple times:**
- Implement idempotent message processing
- Ensure messages are acknowledged after processing
- Check ack deadline is not too short
- Review retry policy configuration

**Dead letter queue filling up:**
- Investigate root cause of message failures
- Check application logs for errors
- Verify message format matches expected schema
- Consider increasing max_delivery_attempts if transient failures

## Additional Resources

- [Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- [Message Ordering](https://cloud.google.com/pubsub/docs/ordering)
- [Dead Letter Queues](https://cloud.google.com/pubsub/docs/dead-letter-topics)
- [Best Practices](https://cloud.google.com/pubsub/docs/publisher)
