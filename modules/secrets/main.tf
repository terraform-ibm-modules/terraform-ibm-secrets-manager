##############################################################################
# Secret Group
##############################################################################

# Fetch all secret groups once
data "ibm_sm_secret_groups" "all" {
  instance_id   = var.existing_sm_instance_guid
  region        = var.existing_sm_instance_region
  endpoint_type = var.endpoint_type
}

locals {
  new_group_map = {
    for sg in var.secrets :
    sg.secret_group_name => {
      secret_group_name                = sg.secret_group_name
      secret_group_description         = sg.secret_group_description
      secret_group_create_access_group = sg.create_access_group
      secret_group_access_group_name   = sg.access_group_name
      secret_group_access_group_roles  = sg.access_group_roles
      secret_group_access_group_tags   = sg.access_group_tags
    }
    if !sg.existing_secret_group
  }

  # Map group name -> id from the provider list
  existing_group_id_by_name = {
    for idx, g in data.ibm_sm_secret_groups.all.secret_groups :
    g.name => g.id
  }
}


module "secret_groups" {
  for_each                 = local.new_group_map
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
  secrets = flatten([
    for sg in var.secrets : [
      for s in sg.secrets : merge(
        {
          secret_group_id = sg.existing_secret_group ? lookup(local.existing_group_id_by_name, sg.secret_group_name, null) : module.secret_groups[sg.secret_group_name].secret_group_id
        },
        s
      )
    ]
  ])
}

# create secret
module "secrets" {
  for_each                                    = { for obj in local.secrets : "${obj.secret_group_id}:${obj.secret_name}" => obj }
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
