##############################################################################
# Outputs
##############################################################################

output "secret_groups" {
  description = "IDs of the created Secret Group"
  value       = module.secret_groups
}

output "secrets" {
  description = "List of secret mananger secret config data"
  value       = module.secrets
}
