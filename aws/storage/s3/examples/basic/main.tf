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

module "s3_bucket" {
  source = "../../"

  config_file = "config.yaml"
}

output "bucket_id" {
  value = module.s3_bucket.resource_id
}

output "bucket_arn" {
  value = module.s3_bucket.resource_arn
}

output "bucket_name" {
  value = module.s3_bucket.resource_name
}
