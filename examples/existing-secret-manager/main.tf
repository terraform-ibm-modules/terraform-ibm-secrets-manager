module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
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
  source                    = "../.."
  existing_sm_instance_crn  = var.existing_sm_instance_crn
  secrets_manager_name      = "${var.prefix}-secrets-manager"
  resource_group_id         = module.resource_group.resource_group_id
  enable_event_notification = true
  existing_en_instance_crn  = module.event_notification.crn
}
