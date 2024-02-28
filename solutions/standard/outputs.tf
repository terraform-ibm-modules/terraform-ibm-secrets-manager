output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "secrets_manager_guid" {
  description = "GUID of Secrets-Manager instance"
  value       = module.secrets_manager.secrets_manager_guid
}
