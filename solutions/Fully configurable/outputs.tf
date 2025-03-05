output "resource_group_name" {
  description = "Resource group name"
  value       = var.existing_secrets_manager_crn == null ? module.resource_group[0].resource_group_name : data.ibm_resource_instance.existing_sm[0].resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = var.existing_secrets_manager_crn == null ? module.resource_group[0].resource_group_id : data.ibm_resource_instance.existing_sm[0].resource_group_id
}

output "secrets_manager_guid" {
  description = "GUID of Secrets Manager instance"
  value       = local.secrets_manager_guid
}

output "secrets_manager_id" {
  description = "ID of Secrets Manager instance. Same value as secrets_manager_guid"
  value       = var.existing_secrets_manager_crn == null ? module.secrets_manager.secrets_manager_id : local.secrets_manager_guid
}

output "secrets_manager_name" {
  value       = var.existing_secrets_manager_crn == null ? module.secrets_manager.secrets_manager_name : data.ibm_resource_instance.existing_sm[0].resource_name
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
