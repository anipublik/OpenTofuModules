output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_kubernetes_cluster.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_kubernetes_cluster.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "node_resource_group" {
  description = "Node resource group name"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
