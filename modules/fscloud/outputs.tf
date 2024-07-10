##############################################################################
# Outputs
##############################################################################

output "secrets_manager_guid" {
  value       = module.secrets_manager.secrets_manager_guid
  description = "GUID of Secrets Manager instance"
}

output "secrets_manager_id" {
  value       = module.secrets_manager.secrets_manager_id
  description = "ID of the Secrets Manager instance"
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

output "secret_groups" {
  value       = module.secrets_manager.secret_groups
  description = "IDs of the created Secret Group"
}

output "secrets" {
  value       = module.secrets_manager.secrets
  description = "List of secret mananger secret config data"
}
