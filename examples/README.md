# Examples

End-to-end examples demonstrating multi-module deployments and common patterns.

## Structure

```
examples/
├── aws/
│   ├── three-tier-app/          # VPC + ALB + EKS + RDS
│   ├── serverless-api/          # API Gateway + Lambda + DynamoDB
│   └── data-pipeline/           # S3 + Lambda + SQS + RDS
├── azure/
│   ├── three-tier-app/          # VNet + App Gateway + AKS + SQL
│   ├── serverless-api/          # Functions + CosmosDB + API Management
│   └── data-pipeline/           # Blob + Functions + Service Bus + SQL
└── gcp/
    ├── three-tier-app/          # VPC + Load Balancer + GKE + Cloud SQL
    ├── serverless-api/          # Cloud Run + Firestore + API Gateway
    └── data-pipeline/           # GCS + Cloud Functions + Pub/Sub + Cloud SQL
```

## AWS Examples

### [Three-Tier Application](./aws/three-tier-app/README.md)
Complete web application stack:
- VPC with public and private subnets
- Application Load Balancer with WAF
- EKS cluster for application tier
- RDS PostgreSQL for data tier
- ElastiCache Redis for session storage
- S3 for static assets with CloudFront

### [Serverless API](./aws/serverless-api/README.md)
Serverless REST API:
- API Gateway with custom domain
- Lambda functions with VPC integration
- DynamoDB tables with GSIs
- Secrets Manager for API keys
- CloudWatch Logs and X-Ray tracing

### [Data Pipeline](./aws/data-pipeline/README.md)
Event-driven data processing:
- S3 bucket for data ingestion
- Lambda for data transformation
- SQS for job queuing
- RDS for processed data storage
- EventBridge for orchestration

## Azure Examples

### [Three-Tier Application](./azure/three-tier-app/README.md)
Complete web application stack:
- VNet with subnets and NSGs
- Application Gateway with WAF
- AKS cluster for application tier
- Azure SQL for data tier
- Azure Cache for Redis for session storage
- Blob storage with Azure CDN

### [Serverless API](./azure/serverless-api/README.md)
Serverless REST API:
- Azure Functions with HTTP triggers
- CosmosDB for data storage
- API Management for gateway
- Key Vault for secrets
- Application Insights for monitoring

### [Data Pipeline](./azure/data-pipeline/README.md)
Event-driven data processing:
- Blob storage for data ingestion
- Azure Functions for transformation
- Service Bus for messaging
- Azure SQL for processed data
- Event Grid for orchestration

## GCP Examples

### [Three-Tier Application](./gcp/three-tier-app/README.md)
Complete web application stack:
- VPC with subnets and firewall rules
- Cloud Load Balancing with Cloud Armor
- GKE cluster for application tier
- Cloud SQL PostgreSQL for data tier
- Memorystore Redis for session storage
- Cloud Storage with Cloud CDN

### [Serverless API](./gcp/serverless-api/README.md)
Serverless REST API:
- Cloud Run services
- Firestore for data storage
- API Gateway for routing
- Secret Manager for secrets
- Cloud Logging and Trace

### [Data Pipeline](./gcp/data-pipeline/README.md)
Event-driven data processing:
- Cloud Storage for data ingestion
- Cloud Functions for transformation
- Pub/Sub for messaging
- Cloud SQL for processed data
- Cloud Scheduler for orchestration

## Running Examples

Each example includes:
- `README.md` — Architecture diagram and deployment guide
- `main.tf` — Module composition
- `*.yaml` — Configuration files for each module
- `outputs.tf` — Stack outputs

To deploy an example:

```bash
# Navigate to example
cd examples/aws/three-tier-app

# Review configuration files
ls *.yaml

# Initialize
tofu init

# Plan
tofu plan

# Apply
tofu apply
```

## Cost Estimates

Each example README includes estimated monthly costs for:
- Development environment (minimal resources)
- Staging environment (moderate resources)
- Production environment (HA, multi-AZ)

Use [Infracost](https://www.infracost.io/) for detailed cost breakdowns:

```bash
infracost breakdown --path .
```

## Contributing

To add a new example:
1. Create directory under appropriate provider
2. Include all YAML configs and main.tf
3. Write comprehensive README with architecture diagram
4. Test deployment end-to-end
5. Document estimated costs
6. Submit PR
