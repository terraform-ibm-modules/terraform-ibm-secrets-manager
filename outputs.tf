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

##############################################################################
