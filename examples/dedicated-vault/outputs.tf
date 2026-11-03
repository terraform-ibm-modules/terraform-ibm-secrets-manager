output "secrets_manager_guid" {
  value       = module.secrets_manager.secrets_manager_guid
  description = "GUID of Secrets Manager instance."
}

output "secrets_manager_region" {
  value       = module.secrets_manager.secrets_manager_region
  description = "Region of the Secrets Manager instance"
}

output "vault_api_endpoint" {
  value       = data.ibm_sm_instance.vault.endpoints[0].public[0].vault_api
  description = "Public Vault API endpoint of the Vault Dedicated instance"
}
