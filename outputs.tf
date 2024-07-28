##############################################################################
# Outputs
##############################################################################

output "secrets_manager_guid" {
  value       = local.secrets_manager_guid
  description = "GUID of Secrets Manager instance"
}

output "secrets_manager_id" {
  value       = ibm_resource_instance.secrets_manager_instance.id
  description = "ID of the Secrets Manager instance"
}

output "secrets_manager_name" {
  value       = ibm_resource_instance.secrets_manager_instance.name
  description = "Name of the Secrets Manager instance"
}

output "secrets_manager_crn" {
  value       = ibm_resource_instance.secrets_manager_instance.crn
  description = "CRN of the Secrets Manager instance"
}

output "secrets_manager_region" {
  value       = var.region
  description = "Region of the Secrets Manager instance"
}

output "secret_groups" {
  value       = module.secrets.secret_groups
  description = "IDs of the created Secret Group"
}

output "secrets" {
  value       = module.secrets.secrets
  description = "List of secret mananger secret config data"
}

##############################################################################
