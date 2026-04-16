# GCP GCE Module

Production-hardened Google Compute Engine instance with shielded VM and encryption.

## Features

- **Shielded VM** — Secure boot and vTPM
- **Encrypted Disks** — Customer-managed encryption
- **OS Login** — IAM-based SSH access
- **Instance Groups** — Load balancer integration
- **Metadata** — Startup scripts

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: app-server
  team: platform
  cost_center: eng-001

instance:
  machine_type: n2-standard-2
  zone: us-central1-a
  image: debian-cloud/debian-11
  disk_size_gb: 20
  disk_type: pd-ssd
  
  enable_secure_boot: true
  enable_vtpm: true
  enable_integrity_monitoring: true
  
  metadata:
    enable-oslogin: "TRUE"
  
  startup_script: |
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
  
  create_instance_group: true
  named_ports:
    - name: http
      port: 80

networking:
  network: projects/my-project/global/networks/main
  subnetwork: projects/my-project/regions/us-central1/subnetworks/app

security:
  public_access: false
  encryption_enabled: true

reliability:
  deletion_protection: true

gcp:
  project_id: my-project

tags:
  application: web-app
```

## Usage

```hcl
module "gce" {
  source = "./gcp/compute/gce"
  config_file = "gce.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Instance ID |
| `instance_self_link` | Instance self link |
| `private_ip` | Private IP address |
| `public_ip` | Public IP address |
