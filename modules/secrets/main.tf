##############################################################################
# Secret Group
##############################################################################

locals {
  secret_groups = flatten([
    for secret_group in var.secrets :
    secret_group.existing_secret_group ? [] : [{
      secret_group_name        = secret_group.secret_group_name
      secret_group_description = secret_group.secret_group_description
    }]
  ])
}

data "ibm_sm_secret_groups" "existing_secret_groups" {
  instance_id   = var.existing_sm_instance_guid
  region        = var.existing_sm_instance_region
  endpoint_type = var.endpoint_type
}

module "secret_groups" {
  for_each                 = { for obj in local.secret_groups : obj.secret_group_name => obj }
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.2.3"
  region                   = var.existing_sm_instance_region
  secrets_manager_guid     = var.existing_sm_instance_guid
  secret_group_name        = each.value.secret_group_name
  secret_group_description = each.value.secret_group_description
  endpoint_type            = var.endpoint_type
}

##############################################################################
# Secrets
##############################################################################

locals {
  secrets = flatten([
    for secret_group in var.secrets :
    secret_group.existing_secret_group ? [
      for secret in secret_group.secrets : merge({
        secret_group_id = data.ibm_sm_secret_groups.existing_secret_groups.secret_groups[index(data.ibm_sm_secret_groups.existing_secret_groups.secret_groups[*].name, secret_group.secret_group_name)].id
      }, secret)
      ] : [
      for secret in secret_group.secrets : merge({
        secret_group_id = module.secret_groups[secret_group.secret_group_name].secret_group_id
      }, secret)
    ]
  ])
}

# create secret
module "secrets" {
  for_each                                    = { for obj in local.secrets : obj.secret_name => obj }
  source                                      = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                                     = "1.7.0"
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
}
