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

module "eks" {
  source = "../../"

  config_file = "config.yaml"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.resource_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
