module "example" {
  source = "../../"  # Points to parent module directory
  
  config_file = "config.yaml"
}

# Outputs for testing
output "resource_id" {
  value = module.example.resource_id
}

output "resource_name" {
  value = module.example.resource_name
}
