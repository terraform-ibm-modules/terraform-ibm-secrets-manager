##############################################################################
# Secret Group (lookup only; no creation)
##############################################################################

data "ibm_sm_secret_groups" "existing_secret_groups" {
  instance_id   = var.existing_sm_instance_guid
  region        = var.existing_sm_instance_region
  endpoint_type = var.endpoint_type
}

##############################################################################
# Secrets
##############################################################################

locals {
  # We keep the same input structure for var.secrets, including fields like
  # existing_secret_group, create_access_group, access_group_* etc.,
  # but we always resolve to an existing group's ID.
  secrets = flatten([
    for secret_group in var.secrets : [
      for secret in secret_group.secrets : merge(
        {
          secret_group_id = data.ibm_sm_secret_groups.existing_secret_groups.secret_groups[
            index(
              data.ibm_sm_secret_groups.existing_secret_groups.secret_groups[*].name,
              secret_group.secret_group_name
            )
          ].id
        },
        secret
      )
    ]
  ])
}

# create secret
module "secrets" {
  # Interface unchanged
  for_each                                    = { for obj in local.secrets : obj.secret_name => obj }
  source                                      = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                                     = "1.9.0"

  region                                      = var.existing_sm_instance_region
  secrets_manager_guid                        = var.existing_sm_instance_guid
  endpoint_type                               = var.endpoint_type

  secret_group_id                             = each.value.secret_group_id
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