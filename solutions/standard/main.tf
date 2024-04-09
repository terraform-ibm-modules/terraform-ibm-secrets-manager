########################################################################################################################
# Resource Group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

#######################################################################################################################
# KMS Key
#######################################################################################################################
locals {
  kms_key_crn = var.existing_sm_kms_key_crn != null ? var.existing_sm_kms_key_crn : module.kms[0].keys[format("%s.%s", var.sm_key_ring_name, var.sm_key_name)].crn
}
# KMS root key for Secrets Manager COS bucket
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = var.existing_sm_kms_key_crn != null ? 0 : 1 # no need to create any KMS resources if passing an existing key, or bucket
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.8.5"
  create_key_protect_instance = false
  region                      = var.kms_region
  existing_kms_instance_guid  = var.existing_kms_guid
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name         = var.sm_key_ring_name
      existing_key_ring     = false
      force_delete_key_ring = true
      keys = [
        {
          key_name                 = var.sm_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}

########################################################################################################################
# Secrets Manager
########################################################################################################################

module "secrets_manager" {
  source               = "../.."
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  secrets_manager_name = var.secrets_manager_instance_name
  sm_service_plan      = var.service_plan
  service_endpoints    = var.service_endpoints
  sm_tags              = var.secret_manager_tags
  # kms dependency
  kms_encryption_enabled            = true
  existing_kms_instance_guid        = var.existing_kms_guid
  kms_key_crn                       = local.kms_key_crn
  skip_kms_iam_authorization_policy = var.skip_kms_iam_authorization_policy
  # event notifications dependency
  enable_event_notification        = var.existing_en_instance_crn != null ? true : false
  existing_en_instance_crn         = var.existing_en_instance_crn
  skip_en_iam_authorization_policy = var.skip_en_iam_authorization_policy
  endpoint_type                    = var.service_endpoints == "private" ? var.service_endpoints : "public"
}
