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
  value       = "Congratulations! Click the link below to go your Secrets Manager instance. Refer to this deployment guide/documentation for more information."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "View Secrets Manager"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = module.secrets_manager.secrets_manager_dashboard_url
  description = "primary url"
}

output "next_step_secondary_label" {
  value       = "Check out related Deployable Architectures"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/catalog?search=Secrets%20Manager%20label%3Adeployable_architecture#search_results"
  description = "Secondary url"
}
