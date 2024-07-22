##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

locals {
  parsed_existing_sm_instance_crn = var.existing_sm_instance_crn != null ? split(":", var.existing_sm_instance_crn) : []
  existing_sm_region              = length(local.parsed_existing_sm_instance_crn) > 0 ? local.parsed_existing_sm_instance_crn[5] : null
}

data "ibm_resource_instance" "existing_sm" {
  count      = var.existing_sm_instance_crn == null ? 0 : 1
  identifier = var.existing_sm_instance_crn
}
##############################################################################
# Event Notification
##############################################################################

module "event_notifications" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.6.5"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public"
  region            = var.region
}

##############################################################################
# Key Protect
##############################################################################

module "key_protect" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "4.13.4"
  key_protect_instance_name = "${var.prefix}-key-protect"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  keys = [
    {
      key_ring_name         = "${var.prefix}-sm"
      force_delete_key_ring = true
      keys = [
        {
          key_name     = "${var.prefix}-sm-key"
          force_delete = true
        }
      ]
    }
  ]
}

##############################################################################
# Secrets Manager
##############################################################################

module "secrets_manager" {
  source                     = "../.."
  resource_group_id          = module.resource_group.resource_group_id
  existing_sm_instance_crn   = var.existing_sm_instance_crn
  secrets_manager_name       = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  region                     = var.region
  sm_service_plan            = "trial"
  sm_tags                    = var.resource_tags
  kms_encryption_enabled     = true
  existing_kms_instance_guid = module.key_protect.kms_guid
  kms_key_crn                = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].crn
  enable_event_notification  = true
  existing_en_instance_crn   = module.event_notifications.crn
}
