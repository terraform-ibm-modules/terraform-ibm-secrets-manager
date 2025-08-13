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

output "secrets_manager_crn" {
  description = "CRN of Secrets Manager instance."
  value       = module.secrets_manager.secrets_manager_crn
}

output "next_steps_text" {
  value       = "Now, you can use Secrets Manager to manage sensitive data like passwords and API keys."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Secrets Manager"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/services/secrets-manager/${module.secrets_manager.secrets_manager_crn}"
  description = "primary url"
}
