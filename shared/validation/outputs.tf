output "validation_passed" {
  description = "True once all terraform_data.validate preconditions hold. Referencing this output forces precondition evaluation."
  value       = terraform_data.validate.id != ""
}

output "config" {
  description = "Validated configuration (passthrough)"
  value       = local.config
}
