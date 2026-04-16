terraform {
  required_version = ">= 1.7.0"
}

module "example" {
  source = "../../"

  config_file = "config.yaml"
}

output "resource_id" {
  value = module.example.resource_id
}
