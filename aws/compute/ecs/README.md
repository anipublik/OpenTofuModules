# AWS ECS Module

Production-hardened ECS Fargate service with auto-scaling and load balancing.

## Features

- **Fargate** — Serverless container execution
- **Auto Scaling** — Target tracking based on CPU/memory
- **Load Balancer Integration** — ALB target group registration
- **Service Discovery** — AWS Cloud Map integration
- **Container Insights** — Enhanced monitoring
- **Secrets Management** — Secrets Manager integration
- **Private Subnet** — Tasks deployed in private subnets

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: api-service
  team: platform
  cost_center: eng-001

service:
  cluster_name: production-cluster
  desired_count: 3
  
  task_definition:
    cpu: 1024
    memory: 2048
    
    containers:
      - name: api
        image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/api:latest
        port: 8080
        
        environment:
          - name: ENV
            value: production
        
        secrets:
          - name: DATABASE_PASSWORD
            valueFrom: arn:aws:secretsmanager:us-east-1:123456789012:secret:db-password
  
  auto_scaling:
    min_capacity: 2
    max_capacity: 20
    target_cpu: 70
    target_memory: 80
  
  load_balancer:
    target_group_arn: arn:aws:elasticloadbalancing:...
    container_name: api
    container_port: 8080

networking:
  subnet_ids:
    - subnet-11111111
    - subnet-22222222
  security_group_ids:
    - sg-ecs-tasks

security:
  encryption_enabled: true

tags:
  application: api
```

## Usage

```hcl
module "ecs" {
  source = "./aws/compute/ecs"
  config_file = "ecs-service.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | ECS service ID |
| `resource_arn` | ECS service ARN |
| `service_name` | ECS service name |
| `task_definition_arn` | Task definition ARN |
