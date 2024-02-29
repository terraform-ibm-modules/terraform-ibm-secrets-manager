module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect All Inclusive
##############################################################################

module "key_protect" {
  count                     = var.existing_kms_instance_guid == null ? 1 : 0
  source                    = "terraform-ibm-modules/key-protect-all-inclusive/ibm"
  version                   = "4.6.0"
  key_protect_instance_name = "${var.prefix}-key-protect"
  key_protect_endpoint_type = "private-only"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  resource_tags             = var.resource_tags
  keys = [
    {
      key_ring_name     = "secrets-manager"
      existing_key_ring = false
      keys = [
        {
          key_name = "${var.prefix}-secrets-manager"
        }
      ]
    }
  ]
}

##############################################################################
# VPC
##############################################################################
resource "ibm_is_vpc" "vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.0.4"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public"
  region            = var.en_region
}

module "secrets_manager" {
  source                     = "../../modules/fscloud"
  resource_group_id          = module.resource_group.resource_group_id
  region                     = var.region
  secrets_manager_name       = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_tags                    = var.resource_tags
  existing_kms_instance_guid = var.existing_kms_instance_guid == null ? module.key_protect[0].kms_guid : var.existing_kms_instance_guid
  kms_key_crn                = var.existing_kms_instance_guid == null ? module.key_protect[0].keys["secrets-manager.${var.prefix}-secrets-manager"].crn : var.kms_key_crn
  existing_en_instance_crn   = module.event_notification.crn
  vpc_crn                    = ibm_is_vpc.vpc.crn
  cbr_zone_name              = "${var.prefix}-CBR-zone"
}
