output "resource_group_name" {
  description = "Resource group name"
  value       = module.secrets_manager.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.secrets_manager.resource_group_id
}

output "secrets_manager_guid" {
  description = "GUID of Secrets Manager instance"
  value       = module.secrets_manager.secrets_manager_guid
}

output "secrets_manager_id" {
  description = "ID of Secrets Manager instance."
  value       = module.secrets_manager.secrets_manager_id
}
