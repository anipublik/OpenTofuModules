output "resource_id" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.this.id
}

output "resource_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "resource_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "resource_region" {
  description = "S3 bucket region"
  value       = aws_s3_bucket.this.region
}

output "bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
