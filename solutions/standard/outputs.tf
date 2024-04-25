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
  value       = local.secrets_manager_guid
}

output "secrets_manager_id" {
  description = "ID of Secrets Manager instance"
  value       = var.existing_secrets_manager_crn == null ? module.secrets_manager[local.secrets_manager_name].secrets_manager_id : null
}

output "secrets_manager_name" {
  value       = var.existing_secrets_manager_crn == null ? module.secrets_manager[local.secrets_manager_name].secrets_manager_name : null
  description = "Name of the Secrets Manager instance"
}

output "secrets_manager_crn" {
  value       = local.secrets_manager_crn
  description = "CRN of the Secrets Manager instance"
}

output "secrets_manager_region" {
  value       = local.secrets_manager_region
  description = "Region of the Secrets Manager instance"
}
