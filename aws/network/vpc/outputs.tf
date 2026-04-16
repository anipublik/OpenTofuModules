output "resource_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "resource_arn" {
  description = "VPC ARN"
  value       = aws_vpc.this.arn
}

output "resource_name" {
  description = "VPC name"
  value       = local.vpc_name
}

output "resource_region" {
  description = "VPC region"
  value       = local.config.meta.region
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

output "vpc_endpoint_s3_id" {
  description = "S3 VPC Endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_dynamodb_id" {
  description = "DynamoDB VPC Endpoint ID"
  value       = aws_vpc_endpoint.dynamodb.id
}
