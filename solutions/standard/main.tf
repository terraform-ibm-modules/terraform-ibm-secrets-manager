########################################################################################################################
# Resource Group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

########################################################################################################################
# Secrets Manager
########################################################################################################################

locals {
}

module "secrets_manager" {
  source                            = "../.."
  resource_group_id                 = module.resource_group.resource_group_id
  region                            = var.region
  secrets_manager_name              = var.secrets_manager_instance_name
  sm_service_plan                   = var.service_plan
  service_endpoints                 = var.service_endpoints
  kms_encryption_enabled            = var.enable_kms_encryption
  existing_kms_instance_guid        = var.existing_kms_instance_guid
  kms_key_crn                       = var.existing_kms_key_crn
  skip_kms_iam_authorization_policy = var.skip_kms_iam_authorization_policy
  sm_tags                           = var.secret_manager_tags
  skip_en_iam_authorization_policy  = var.skip_en_iam_authorization_policy
  enable_event_notification         = var.enable_event_notification
  existing_en_instance_crn          = var.existing_en_instance_crn
}
