output "secrets_manager_guid" {
  value       = module.secrets_manager.secrets_manager_guid
  description = "GUID of Secrets-Manager instance in which IAM engine was configured"
}
