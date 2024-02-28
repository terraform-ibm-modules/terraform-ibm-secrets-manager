##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone
##############################################################################
module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.18.0"
  name             = var.cbr_zone_name
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = var.vpc_crn,
  }]
}

module "secrets_manager" {
  source                           = "../.."
  resource_group_id                = var.resource_group_id
  region                           = var.region
  secrets_manager_name             = var.secrets_manager_name #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_service_plan                  = "standard"
  sm_tags                          = var.sm_tags
  service_endpoints                = "private"
  kms_encryption_enabled           = true
  existing_kms_instance_guid       = var.existing_kms_instance_guid
  enable_event_notification        = true
  existing_en_instance_crn         = var.existing_en_instance_crn
  skip_en_iam_authorization_policy = false
  kms_key_crn                      = var.kms_key_crn
  cbr_rules = [
    {
      description      = "${var.secrets_manager_name} access only from vpc"
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
