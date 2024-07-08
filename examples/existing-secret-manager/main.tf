module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

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

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.6.5"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public"
  region            = var.en_region
}

module "secrets_manager" {
  source                     = "../.."
  existing_sm_instance_crn   = var.existing_sm_instance_crn 
  secrets_manager_name       = "${var.prefix}-secrets-manager"
  resource_group_id          = module.resource_group.resource_group_id
  kms_encryption_enabled     = true
  existing_kms_instance_guid = module.key_protect.kms_guid
  kms_key_crn                = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].crn
  enable_event_notification  = true
  existing_en_instance_crn   = module.event_notification.crn
}
