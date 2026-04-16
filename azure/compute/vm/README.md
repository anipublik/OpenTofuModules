# Azure VM Module

Production-hardened Azure Virtual Machine Scale Set with auto-scaling and managed identity.

## Features

- **Auto Scaling** — CPU-based scaling rules
- **Managed Identity** — System-assigned identity
- **Automatic OS Upgrades** — Rolling upgrades
- **Boot Diagnostics** — Troubleshooting support
- **Availability Zones** — Multi-zone deployment

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: app-servers
  team: platform
  cost_center: eng-001

vm:
  sku: Standard_D2s_v3
  instances: 3
  admin_username: azureuser
  ssh_public_key: "ssh-rsa AAAA..."
  
  image:
    publisher: Canonical
    offer: 0001-com-ubuntu-server-focal
    sku: 20_04-lts-gen2
    version: latest
  
  os_disk_type: Premium_LRS
  os_disk_size_gb: 30
  
  autoscaling:
    min_instances: 2
    max_instances: 10
    scale_out_cpu_threshold: 70
    scale_in_cpu_threshold: 30

networking:
  subnet_id: /subscriptions/.../subnets/app-subnet

azure:
  resource_group: production-rg

tags:
  application: web-app
```

## Usage

```hcl
module "vm" {
  source = "./azure/compute/vm"
  config_file = "vm.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | VMSS ID |
| `vmss_id` | VMSS ID |
| `vmss_unique_id` | VMSS unique ID |
| `principal_id` | System identity principal ID |
