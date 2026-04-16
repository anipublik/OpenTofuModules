# AWS EC2 Module

Production-hardened EC2 instances with IMDSv2, encrypted EBS, and auto-scaling support.

## Features

- **IMDSv2 Required** — Prevents SSRF attacks
- **Encrypted EBS** — All volumes encrypted with KMS
- **Auto Scaling** — Launch template with ASG support
- **Systems Manager** — SSM Session Manager for secure access
- **CloudWatch Monitoring** — Detailed monitoring enabled
- **Private Subnet** — Instances deployed in private subnets

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: app-server
  team: platform
  cost_center: eng-001

instance:
  ami_id: ami-0c55b159cbfafe1f0
  instance_type: t3.medium
  key_name: my-key-pair
  
  user_data: |
    #!/bin/bash
    yum update -y
    yum install -y amazon-ssm-agent
  
  root_volume:
    size: 30
    type: gp3
    encrypted: true
  
  additional_volumes:
    - device_name: /dev/sdf
      size: 100
      type: gp3
      encrypted: true

auto_scaling:
  enabled: true
  min_size: 2
  max_size: 10
  desired_capacity: 3
  health_check_type: ELB
  health_check_grace_period: 300

networking:
  subnet_ids:
    - subnet-11111111
    - subnet-22222222
  security_group_ids:
    - sg-app-servers

security:
  imdsv2_required: true
  encryption_enabled: true

tags:
  application: web-app
```

## Usage

```hcl
module "ec2" {
  source = "./aws/compute/ec2"
  config_file = "ec2-instances.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Launch template ID |
| `resource_arn` | Launch template ARN |
| `asg_id` | Auto Scaling Group ID |
| `asg_name` | Auto Scaling Group name |
