output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Resource group name"
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "Resource group ID"
}

output "secrets_manager_crn" {
  value       = var.provision_secrets_manager == true ? module.secrets_manager[0].secrets_manager_crn : null
  description = "CRN of the secrets manager instance"
}
