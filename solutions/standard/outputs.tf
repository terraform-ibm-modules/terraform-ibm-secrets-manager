output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "secrets_manager_guid" {
  description = "GUID of Secrets Manager instance"
  value       = module.secrets_manager.secrets_manager_guid
}

output "secrets_manager_id" {
  description = "ID of Secrets Manager instance"
  value       = module.secrets_manager.secrets_manager_id
}

output "secrets_manager_name" {
  value       = module.secrets_manager.secrets_manager_name
  description = "Name of the Secrets Manager instance"
}

output "secrets_manager_crn" {
  value       = module.secrets_manager.secrets_manager_crn
  description = "CRN of the Secrets Manager instance"
}

output "secrets_manager_region" {
  value       = module.secrets_manager.secrets_manager_region
  description = "Region of the Secrets Manager instance"
}
