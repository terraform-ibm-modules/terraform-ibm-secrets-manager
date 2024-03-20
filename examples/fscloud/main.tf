module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
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
  existing_kms_instance_guid = var.existing_kms_instance_guid
  kms_key_crn                = var.kms_key_crn
  existing_en_instance_crn   = module.event_notification.crn
  vpc_crn                    = ibm_is_vpc.vpc.crn
  cbr_zone_name              = "${var.prefix}-CBR-zone"
}
