output "name" {
  description = "Generated resource name"
  value       = local.name
}

output "name_prefix" {
  description = "Name prefix for resources that support it"
  value       = "${local.name}-"
}
