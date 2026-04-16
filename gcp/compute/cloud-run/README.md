# GCP Cloud Run Module

Production-hardened Cloud Run service with autoscaling, VPC connectivity, and secret management.

## Features

- **Autoscaling** — Scale from 0 to max instances based on traffic
- **VPC Connector** — Private connectivity to VPC resources
- **Secret Management** — Inject secrets from Secret Manager as environment variables
- **Service Account** — Custom service account for workload identity
- **Resource Limits** — Configure CPU and memory per container
- **IAM-Based Access** — Public or private service with IAM authentication
- **Container Port** — Configurable container port
- **Environment Variables** — Static and secret-based configuration

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: api-service
  team: backend
  cost_center: eng-002

gcp:
  project_id: my-gcp-project

service:
  image: gcr.io/my-project/api:v1.2.3
  port: 8080
  
  min_instances: 1                     # 0 for scale-to-zero
  max_instances: 100
  
  cpu: 2000m                           # 2 vCPU
  memory: 4Gi                          # 4GB RAM
  
  environment_variables:
    NODE_ENV: production
    LOG_LEVEL: info
    DATABASE_HOST: 10.0.0.3
  
  secrets:
    DATABASE_PASSWORD:
      secret: database-password
      version: latest
    API_KEY:
      secret: api-key
      version: "3"
  
  service_account: api-service@my-project.iam.gserviceaccount.com
  
  invoker_members:                     # Only if public_access: false
    - serviceAccount:frontend@my-project.iam.gserviceaccount.com
    - user:admin@example.com

networking:
  vpc_connector: projects/my-project/locations/us-central1/connectors/vpc-connector
  vpc_egress: PRIVATE_RANGES_ONLY      # or ALL_TRAFFIC

security:
  public_access: false                 # Set true for public internet access
  encryption_enabled: true
  deletion_protection: false

tags:
  project: backend
  compliance: pci-dss
```

## Usage

```hcl
module "cloud_run" {
  source = "./gcp/compute/cloud-run"
  config_file = "cloud-run.yaml"
}

output "service_url" {
  value = module.cloud_run.service_url
}

output "service_id" {
  value = module.cloud_run.service_id
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `service_id` | Cloud Run service ID |
| `service_name` | Cloud Run service name |
| `service_url` | Service URL (HTTPS endpoint) |
| `service_uri` | Service URI |

## Resource Limits

**CPU:**
- Minimum: `1000m` (1 vCPU)
- Maximum: `8000m` (8 vCPU)
- Increments: `1000m`

**Memory:**
- Minimum: `128Mi`
- Maximum: `32Gi`
- Common values: `512Mi`, `1Gi`, `2Gi`, `4Gi`, `8Gi`

**CPU/Memory Ratios:**
- 1 vCPU: 512Mi - 4Gi
- 2 vCPU: 1Gi - 8Gi
- 4 vCPU: 2Gi - 16Gi
- 8 vCPU: 4Gi - 32Gi

## Autoscaling

Configure scaling behavior:

```yaml
service:
  min_instances: 1                     # Always-on (no cold starts)
  max_instances: 100                   # Maximum concurrent instances
```

**Scale-to-Zero:**
```yaml
service:
  min_instances: 0                     # Scale to zero when idle
  max_instances: 10
```

**Always-On:**
```yaml
service:
  min_instances: 3                     # Minimum 3 instances always running
  max_instances: 50
```

## VPC Connectivity

Connect to VPC resources (Cloud SQL, Memorystore, etc.):

1. Create VPC Connector:
```bash
gcloud compute networks vpc-access connectors create vpc-connector \
  --region=us-central1 \
  --subnet=vpc-connector-subnet \
  --subnet-project=my-project
```

2. Configure in YAML:
```yaml
networking:
  vpc_connector: projects/my-project/locations/us-central1/connectors/vpc-connector
  vpc_egress: PRIVATE_RANGES_ONLY      # Only private IPs through VPC
```

## Secret Management

Inject secrets from Secret Manager:

```yaml
service:
  secrets:
    DATABASE_PASSWORD:
      secret: database-password        # Secret Manager secret name
      version: latest                  # or specific version number
    API_KEY:
      secret: api-key
      version: "3"
```

Create secrets:
```bash
echo -n "my-secret-value" | gcloud secrets create database-password \
  --data-file=- \
  --replication-policy=automatic
```

## Access Control

### Public Access

```yaml
security:
  public_access: true                  # Anyone can invoke
```

### Private Access (IAM)

```yaml
security:
  public_access: false

service:
  invoker_members:
    - serviceAccount:frontend@my-project.iam.gserviceaccount.com
    - user:admin@example.com
    - group:backend-team@example.com
```

Invoke with authentication:
```bash
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  https://api-service-production-abc123.run.app
```

## Deploying New Versions

Update image in YAML and apply:

```yaml
service:
  image: gcr.io/my-project/api:v1.2.4  # New version
```

```bash
tofu apply
```

Cloud Run automatically:
- Deploys new revision
- Routes 100% traffic to new revision
- Keeps old revisions for rollback

## Security Considerations

- **Private by Default** — Set `public_access: false` for internal services
- **Service Account** — Use dedicated service account with least privilege
- **Secret Manager** — Never put secrets in environment variables, use Secret Manager
- **VPC Egress** — Use `PRIVATE_RANGES_ONLY` to prevent data exfiltration
- **HTTPS Only** — Cloud Run enforces HTTPS, no HTTP option
- **IAM Authentication** — Require authentication for sensitive services

## Cost Optimization

- **Scale-to-Zero** — Set `min_instances: 0` for low-traffic services
- **Right-Size Resources** — Start with 1 vCPU / 512Mi and scale up if needed
- **Request Timeout** — Set shorter timeout to avoid long-running requests
- **Concurrency** — Increase concurrency per instance to reduce instance count
- **Committed Use** — Purchase Cloud Run committed use for predictable workloads

## Monitoring and Logging

View logs:
```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=api-service-production" \
  --limit 50 \
  --format json
```

View metrics in Cloud Console:
- Request count
- Request latency
- Container CPU utilization
- Container memory utilization
- Instance count

## Troubleshooting

**Service not accessible:**
- Verify IAM permissions if private service
- Check VPC connector if using VPC connectivity
- Ensure container listens on configured port
- Review Cloud Run logs for startup errors

**Cold start latency:**
- Set `min_instances: 1` or higher to keep instances warm
- Optimize container image size
- Use startup probes to signal readiness

**Can't connect to Cloud SQL:**
- Verify VPC connector is configured
- Check service account has Cloud SQL Client role
- Use private IP for Cloud SQL connection
- Ensure `vpc_egress: PRIVATE_RANGES_ONLY` or `ALL_TRAFFIC`

**Out of memory errors:**
- Increase `memory` limit
- Check for memory leaks in application
- Review memory usage metrics in Cloud Monitoring

## Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [VPC Connector](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access)
- [Secret Manager Integration](https://cloud.google.com/run/docs/configuring/secrets)
- [Best Practices](https://cloud.google.com/run/docs/best-practices)
