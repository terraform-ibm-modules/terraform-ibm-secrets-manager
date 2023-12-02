module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "key_protect" {
  source                    = "terraform-ibm-modules/key-protect-all-inclusive/ibm"
  version                   = "4.4.2"
  key_protect_instance_name = "${var.prefix}-key-protect"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  key_map = {
    "${var.prefix}-sm" = ["${var.prefix}-sm-key"]
  }
}

module "secrets_manager" {
  source                     = "../.."
  resource_group_id          = module.resource_group.resource_group_id
  region                     = var.region
  secrets_manager_name       = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_service_plan            = var.sm_service_plan
  sm_tags                    = var.resource_tags
  service_endpoints          = "public-and-private"
  kms_encryption_enabled     = true
  existing_kms_instance_guid = module.key_protect.key_protect_guid
  kms_key_crn                = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].crn
}
