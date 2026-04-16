output "resource_id" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "resource_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "resource_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "resource_region" {
  description = "EKS cluster region"
  value       = local.config.meta.region
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64-encoded CA certificate"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Cluster security group ID"
  value       = aws_security_group.cluster.id
}

output "cluster_oidc_issuer_url" {
  description = "OIDC provider URL for IRSA"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_group_ids" {
  description = "Map of node group names to IDs"
  value       = { for k, v in aws_eks_node_group.this : k => v.id }
}

output "node_security_group_id" {
  description = "Node security group ID"
  value       = aws_security_group.node.id
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM role ARN"
  value       = aws_iam_role.cluster.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.cluster.arn
}
