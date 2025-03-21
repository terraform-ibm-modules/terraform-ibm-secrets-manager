##############################################################################
# Outputs
##############################################################################

output "secrets_manager_guid" {
  value       = local.secrets_manager_guid
  description = "GUID of Secrets Manager instance"
}

output "secrets_manager_id" {
  value       = var.existing_sm_instance_crn != null ? var.existing_sm_instance_crn : ibm_resource_instance.secrets_manager_instance[0].crn
  description = "ID of the Secrets Manager instance"
}


output "secrets_manager_name" {
  value       = var.existing_sm_instance_crn != null ? data.ibm_resource_instance.sm_instance[0].name : ibm_resource_instance.secrets_manager_instance[0].name
  description = "Name of the Secrets Manager instance"
}

output "secrets_manager_crn" {
  value       = var.existing_sm_instance_crn != null ? var.existing_sm_instance_crn : ibm_resource_instance.secrets_manager_instance[0].crn
  description = "CRN of the Secrets Manager instance"
}

output "secrets_manager_region" {
  value       = var.existing_sm_instance_crn != null ? local.existing_sm_region : var.region
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
