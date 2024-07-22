output "resource_group_name" {
  description = "Resource group name"
  value       = var.existing_sm_instance_crn == null ? module.resource_group[0].resource_group_name : data.ibm_resource_instance.existing_sm[0].resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = var.existing_sm_instance_crn == null ? module.resource_group[0].resource_group_name : data.ibm_resource_instance.existing_sm[0].resource_group_id
}

output "secrets_manager_kms_key_crn" {
  value       = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].crn
  description = "CRN of created secret manager KMS key"
}

output "secrets_manager_kms_instance_crn" {
  value       = module.key_protect.key_protect_id
  description = "CRN of created secret manager KMS instance"
}

output "event_notification_instance_crn" {
  value       = module.event_notifications.crn
  description = "CRN of created event notification"
}

output "secrets_manager_instance_crn" {
  value       = module.secrets_manager.secrets_manager_crn
  description = "CRN of created secret manager instance"
}

output "secrets_manager_region" {
  value       = var.existing_sm_instance_crn != null ? local.existing_sm_region : var.region
  description = "Region of the Secrets Manager instance"
}
