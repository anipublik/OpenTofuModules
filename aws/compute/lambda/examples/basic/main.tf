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

module "lambda" {
  source = "../../"

  config_file = "config.yaml"
}

output "function_arn" {
  value = module.lambda.resource_arn
}

output "invoke_arn" {
  value = module.lambda.invoke_arn
}
