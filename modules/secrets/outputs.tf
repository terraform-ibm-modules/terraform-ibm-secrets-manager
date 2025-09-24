##############################################################################
# Outputs
##############################################################################

output "secret_groups" {
  description = "IDs of the created Secret Group"
  value       = module.secret_groups
}

output "secrets" {
  description = "List of secret manager secret config data"
  value       = module.secrets
}

output "loccal_secret_groups" {
  value = local.secret_groups
}

output "loccal_secrets" {
  value = local.secrets
}