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
  description = "ID of Secrets Manager instance."
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

output "next_steps_text" {
  value       = "Congratulations! You successfully deployed your changes. Next, view your Secrets Manager instance."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "View Secrets Manager"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/services/secrets-manager/${local.secrets_manager_crn}"
  description = "primary url"
}
