##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# VPC
##############################################################################
resource "ibm_is_vpc" "vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

##############################################################################
# Create CBR Zone
##############################################################################
module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.32.4"
  name             = "${var.prefix}-CBR-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.vpc.crn,
  }]
}

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "2.4.22"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public"
  region            = var.region
}

##############################################################################
# Parse info from KMS key crn
##############################################################################

module "kms_key_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.kms_key_crn
}

locals {
  kms_service = module.kms_key_crn_parser.service_name
}

module "secrets_manager" {
  source                   = "../../modules/fscloud"
  resource_group_id        = module.resource_group.resource_group_id
  region                   = var.region
  secrets_manager_name     = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_tags                  = var.resource_tags
  is_hpcs_key              = local.kms_service == "hs-crypto" ? true : false
  kms_key_crn              = var.kms_key_crn
  existing_en_instance_crn = module.event_notification.crn
  cbr_rules = [
    {
      description      = "${var.prefix}-secrets-manager access only from vpc"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
      operations = [{
        api_types = [{
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
        }]
      }]
    }
  ]
}
