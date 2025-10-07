##############################################################################
# Secret Group (create only when not existing)
##############################################################################

locals {
  # Build the list of groups to create (skip when existing_secret_group is true)
  secret_groups = flatten([
    for secret_group in var.secrets :
    secret_group.existing_secret_group ? [] : [
      {
        secret_group_name                = secret_group.secret_group_name
        secret_group_description         = secret_group.secret_group_description
        secret_group_create_access_group = secret_group.create_access_group
        secret_group_access_group_name   = secret_group.access_group_name
        secret_group_access_group_roles  = secret_group.access_group_roles
        secret_group_access_group_tags   = secret_group.access_group_tags
      }
    ]
  ])
}

module "secret_groups" {
  for_each                 = { for obj in local.secret_groups : obj.secret_group_name => obj }
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.3.15"
  region                   = var.existing_sm_instance_region
  secrets_manager_guid     = var.existing_sm_instance_guid
  secret_group_name        = each.value.secret_group_name
  secret_group_description = each.value.secret_group_description
  endpoint_type            = var.endpoint_type
  create_access_group      = each.value.secret_group_create_access_group
  access_group_name        = each.value.secret_group_access_group_name
  access_group_roles       = each.value.secret_group_access_group_roles
  access_group_tags        = each.value.secret_group_access_group_tags
}

##############################################################################
# Secrets
##############################################################################

locals {
  # For existing groups, expect secret_group_id to be provided in var.secrets[*]
  # For new groups, use the ID from module.secret_groups
  secrets = flatten([
    for secret_group in var.secrets :
    secret_group.existing_secret_group ? [
      for secret in secret_group.secrets : merge(
        {
          # secret_group.secret_group_id must be provided in input for existing groups
          secret_group_id = secret_group.secret_group_id
        },
        secret
      )
    ] : [
      for secret in secret_group.secrets : merge(
        {
          secret_group_id = module.secret_groups[secret_group.secret_group_name].secret_group_id
        },
        secret
      )
    ]
  ])
}

module "secrets" {
  for_each                                    = { for obj in local.secrets : obj.secret_name => obj }
  source                                      = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                                     = "1.9.0"
  region                                      = var.existing_sm_instance_region
  secrets_manager_guid                        = var.existing_sm_instance_guid
  secret_group_id                             = each.value.secret_group_id
  endpoint_type                               = var.endpoint_type
  secret_name                                 = each.value.secret_name
  secret_description                          = each.value.secret_description
  secret_type                                 = each.value.secret_type
  imported_cert_certificate                   = each.value.imported_cert_certificate
  imported_cert_private_key                   = each.value.imported_cert_private_key
  imported_cert_intermediate                  = each.value.imported_cert_intermediate
  secret_username                             = each.value.secret_username
  secret_labels                               = each.value.secret_labels
  secret_payload_password                     = each.value.secret_payload_password
  secret_auto_rotation                        = each.value.secret_auto_rotation
  secret_auto_rotation_unit                   = each.value.secret_auto_rotation_unit
  secret_auto_rotation_interval               = each.value.secret_auto_rotation_interval
  service_credentials_ttl                     = each.value.service_credentials_ttl
  service_credentials_source_service_crn      = each.value.service_credentials_source_service_crn
  service_credentials_source_service_role_crn = each.value.service_credentials_source_service_role_crn
  service_credentials_source_service_hmac     = each.value.service_credentials_source_service_hmac
  custom_credentials_configurations           = each.value.custom_credentials_configurations
  custom_credentials_parameters               = each.value.custom_credentials_parameters
  job_parameters                              = each.value.job_parameters
}