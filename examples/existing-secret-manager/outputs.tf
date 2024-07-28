output "secrets_manager_guid" {
  value       = module.secrets_manager.secrets_manager_guid
  description = "GUID of Secrets Manager instance."
}

output "secrets_manager_region" {
  value       = module.secrets_manager.secrets_manager_region
  description = "Region of the Secrets Manager instance"
}

output "sm_cred_ouput" {
  description = "output"
  value       = module.secrets_manager_service_credentails
}

output "sm_cred_input" {
  description = "input"
  value       = local.service_credentials_secrets
}
