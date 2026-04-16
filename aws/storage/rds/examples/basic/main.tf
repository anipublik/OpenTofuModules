terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "rds" {
  source = "../../"

  config_file = "config.yaml"
}

output "endpoint" {
  value = module.rds.endpoint
}

output "address" {
  value = module.rds.address
}
