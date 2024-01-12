##############################################################################
# Secrets Manager Module
##############################################################################

# Validation
locals {
  allowed_network = var.service_endpoints == "private" ? "private-only" : "public-and-private"

  # Validation (approach based on https://github.com/hashicorp/terraform/issues/25609#issuecomment-1057614400)
  # tflint-ignore: terraform_unused_declarations
  validate_kms_values = (!var.kms_encryption_enabled && var.kms_key_crn != null) ? tobool("When passing values for var.kms_key_crn, you must set var.kms_encryption_enabled to true. Otherwise unset them to use default encryption") : (!var.kms_encryption_enabled && var.existing_kms_instance_guid != null) ? tobool("When passing values for var.existing_kms_instance_guid, you must set var.kms_encryption_enabled to true. Otherwise unset them to use default encryption") : true
  # tflint-ignore: terraform_unused_declarations
  validate_kms_vars = var.kms_encryption_enabled && var.kms_key_crn == null ? tobool("When setting var.kms_encryption_enabled to true, a value must be passed for var.kms_key_crn") : true
  # tflint-ignore: terraform_unused_declarations
  validate_auth_policy = var.kms_encryption_enabled && var.skip_kms_iam_authorization_policy == false && var.existing_kms_instance_guid == null ? tobool("When var.skip_kms_iam_authorization_policy is set to false, and var.kms_encryption_enabled to true, a value must be passed for var.existing_kms_instance_guid in order to create the auth policy.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_event_notification = var.enable_event_notification && var.existing_en_instance_crn == null ? tobool("When setting var.enable_event_notification to true, a value must be passed for var.existing_en_instance_crn") : true
  # tflint-ignore: terraform_unused_declarations
  validate_endpoint = (var.endpoint_type == "public" && var.service_endpoints == "private") || (var.endpoint_type == "private" && var.service_endpoints == "public") ? tobool("It is not allowed to have conflicting var.endpoint_type and var.service_endpoints values.") : true
}

# Create Secrets Manager Instance
resource "ibm_resource_instance" "secrets_manager_instance" {
  depends_on        = [ibm_iam_authorization_policy.kms_policy]
  name              = var.secrets_manager_name
  service           = "secrets-manager"
  service_endpoints = var.service_endpoints
  plan              = var.sm_service_plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.sm_tags
  parameters = {
    "allowed_network" = local.allowed_network
    "kms_instance"    = var.existing_kms_instance_guid
    "kms_key"         = var.kms_key_crn
  }

  timeouts {
    create = "30m" # Extending provisioning time to 30 minutes
  }
}

locals {
  # determine which service name to use for the policy
  kms_service_name = var.kms_encryption_enabled && var.kms_key_crn != null ? (
    can(regex(".*kms.*", var.kms_key_crn)) ? "kms" : (
      can(regex(".*hs-crypto.*", var.kms_key_crn)) ? "hs-crypto" : null
    )
  ) : null
}

resource "ibm_iam_authorization_policy" "kms_policy" {
  count                       = var.kms_encryption_enabled && !var.skip_kms_iam_authorization_policy ? 1 : 0
  source_service_name         = "secrets-manager"
  source_resource_group_id    = var.resource_group_id
  target_service_name         = local.kms_service_name
  target_resource_instance_id = var.existing_kms_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow all Secrets Manager instances in the resource group ${var.resource_group_id} to read from the ${local.kms_service_name} instance GUID ${var.existing_kms_instance_guid}"
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.kms_policy, ibm_iam_authorization_policy.en_policy]

  create_duration = "30s"
}


locals {
  secrets_manager_guid = tolist(ibm_resource_instance.secrets_manager_instance[*].guid)[0]
}

##############################################################################
# Context Based Restrictions
##############################################################################
module "cbr_rule" {
  count            = length(var.cbr_rules) > 0 ? length(var.cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.17.1"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = local.secrets_manager_guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "secrets-manager"
        operator = "stringEquals"
      }
    ]
  }]
  operations = [{
    api_types = [{
      api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
    }]
  }]
}

##############################################################################
# Event Notification
##############################################################################

# Create IAM Authorization Policies to allow SM to access event notification
resource "ibm_iam_authorization_policy" "en_policy" {
  count                       = var.enable_event_notification == false || var.skip_en_iam_authorization_policy ? 0 : 1
  source_service_name         = "secrets-manager"
  source_resource_group_id    = var.resource_group_id
  target_service_name         = "event-notifications"
  target_resource_instance_id = regex(".*:(.*)::", var.existing_en_instance_crn)[0]
  roles                       = ["Event Source Manager"]
  description                 = "Allow all Secrets Manager instances in the resource group ${var.resource_group_id} 'Event Source Manager' role access on the Event Notification instance GUID ${regex(".*:(.*)::", var.existing_en_instance_crn)[0]}"
}

resource "ibm_sm_en_registration" "sm_en_registration" {
  count                                  = var.enable_event_notification ? 1 : 0
  depends_on                             = [time_sleep.wait_for_authorization_policy]
  instance_id                            = local.secrets_manager_guid
  region                                 = var.region
  event_notifications_instance_crn       = var.existing_en_instance_crn
  event_notifications_source_description = "Secret Manager"
  event_notifications_source_name        = var.secrets_manager_name
  endpoint_type                          = var.endpoint_type
}
