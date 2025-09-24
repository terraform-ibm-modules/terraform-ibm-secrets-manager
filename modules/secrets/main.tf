##############################################################################
# Lookup all groups once
##############################################################################
data "ibm_sm_secret_groups" "all" {
  instance_id   = var.existing_sm_instance_guid
  region        = var.existing_sm_instance_region
  endpoint_type = var.endpoint_type
}

locals {
  # distinct names from inputs; interface unchanged
  distinct_group_names = toset([for sg in var.secrets : sg.secret_group_name])

  # name -> id resolution from the current data read
  group_id_by_name_now = {
    for g in data.ibm_sm_secret_groups.all.secret_groups : g.name => g.id
  }
}

##############################################################################
# Persist a stable mapping name -> id in state
##############################################################################
resource "terraform_data" "group_id" {
  for_each = local.distinct_group_names

  # The only trigger that should cause recomputation is the name change.
  # We put the current resolved id in "input" so it gets stored in state on first apply.
  input = {
    name = each.key
    id   = local.group_id_by_name_now[each.key]
  }
}

locals {
  # Stable, plan-known IDs coming from state after first apply
  stable_group_id_by_name = {
    for name, r in terraform_data.group_id :
    name => r.output.id
  }

  secrets = flatten([
    for sg in var.secrets : [
      for s in sg.secrets : merge(
        {
          secret_group_id = local.stable_group_id_by_name[sg.secret_group_name]
        },
        s
      )
    ]
  ])
}

module "secrets" {
  for_each = { for obj in local.secrets : obj.secret_name => obj }
  source   = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version  = "1.9.0"

  region               = var.existing_sm_instance_region
  secrets_manager_guid = var.existing_sm_instance_guid
  endpoint_type        = var.endpoint_type

  secret_group_id = each.value.secret_group_id
  secret_name     = each.value.secret_name
  secret_description = each.value.secret_description
  secret_type     = each.value.secret_type
  imported_cert_certificate  = each.value.imported_cert_certificate
  imported_cert_private_key  = each.value.imported_cert_private_key
  imported_cert_intermediate = each.value.imported_cert_intermediate
  secret_username            = each.value.secret_username
  secret_labels              = each.value.secret_labels
  secret_payload_password    = each.value.secret_payload_password
  secret_auto_rotation       = each.value.secret_auto_rotation
  secret_auto_rotation_unit  = each.value.secret_auto_rotation_unit
  secret_auto_rotation_interval = each.value.secret_auto_rotation_interval
  service_credentials_ttl                     = each.value.service_credentials_ttl
  service_credentials_source_service_crn      = each.value.service_credentials_source_service_crn
  service_credentials_source_service_role_crn = each.value.service_credentials_source_service_role_crn
  service_credentials_source_service_hmac     = each.value.service_credentials_source_service_hmac
  custom_credentials_configurations           = each.value.custom_credentials_configurations
  custom_credentials_parameters               = each.value.custom_credentials_parameters
  job_parameters                              = each.value.job_parameters
}