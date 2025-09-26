output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Resource group name"
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "Resource group ID"
}

output "secrets_manager_kms_instance_crn" {
  value       = module.key_protect.key_protect_id
  description = "CRN of created secret manager KMS instance"
}

output "event_notifications_instance_crn" {
  value       = module.event_notifications.crn
  description = "CRN of created event notification"
}
