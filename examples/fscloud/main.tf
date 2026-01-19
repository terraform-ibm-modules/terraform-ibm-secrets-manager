##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}


##############################################################################
# Create CBR Zone for Schematics
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

module "cbr_zone_schematics" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.35.10"
  name             = "${var.prefix}-schematics-zone"
  zone_description = "CBR Network zone containing Schematics"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef",
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "schematics"
    }
  }]
}

##############################################################################
# Event Notifications
##############################################################################

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "2.10.39"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  region            = var.region
}

##############################################################################
# Parse info from KMS key crn
##############################################################################

module "kms_key_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.7"
  crn     = var.kms_key_crn
}

locals {
  kms_service = module.kms_key_crn_parser.service_name
}

##############################################################################
# Secrets Manager
##############################################################################

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
      description      = "${var.prefix}-secrets-manager access only from Schematics"
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
            value = module.cbr_zone_schematics.zone_id
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
