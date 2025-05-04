########################################################################################################################
# Resource Group
########################################################################################################################
locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
}

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
  existing_resource_group_name = var.existing_resource_group_name
}

#######################################################################################################################
# KMS Key
#######################################################################################################################
locals {
  kms_key_crn       = var.existing_secrets_manager_crn == null ? (var.existing_secrets_manager_kms_key_crn != null ? var.existing_secrets_manager_kms_key_crn : (var.kms_encryption_enabled == true ? module.kms[0].keys[format("%s.%s", local.kms_key_ring_name, local.kms_key_name)].crn : null)) : var.existing_secrets_manager_kms_key_crn
  kms_key_ring_name = "${local.prefix}${var.kms_key_ring_name}"
  kms_key_name      = "${local.prefix}${var.kms_key_name}"

  kms_region = var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].region : null

  parsed_service_name = var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].service_name : (var.existing_secrets_manager_kms_key_crn != null ? module.kms_key_crn_parser[0].service_name : null)
  is_hpcs_key         = local.parsed_service_name == "hs-crypto" ? true : false

  create_cross_account_auth_policy      = var.existing_secrets_manager_crn == null && !var.skip_sm_kms_iam_authorization_policy && var.ibmcloud_kms_api_key != null
  create_cross_account_hpcs_auth_policy = local.create_cross_account_auth_policy == true && local.is_hpcs_key ? 1 : 0

  kms_service_name  = var.existing_secrets_manager_kms_key_crn != null ? module.kms_key_crn_parser[0].service_name : (var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].service_name : null)
  kms_key_id        = var.existing_secrets_manager_kms_key_crn != null ? module.kms_key_crn_parser[0].resource : (var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].resource : null)
  kms_instance_guid = var.existing_secrets_manager_kms_key_crn != null ? module.kms_key_crn_parser[0].service_instance : (var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].service_instance : null)
  kms_account_id    = var.existing_secrets_manager_kms_key_crn != null ? module.kms_key_crn_parser[0].account_id : (var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].account_id : null)
}

data "ibm_iam_account_settings" "iam_account_settings" {
  count = local.create_cross_account_auth_policy ? 1 : 0
}

########################################################################################################################
# Parse KMS info from given CRNs
########################################################################################################################

module "kms_instance_crn_parser" {
  count   = var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_kms_instance_crn
}

module "kms_key_crn_parser" {
  count   = var.existing_secrets_manager_kms_key_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_secrets_manager_kms_key_crn
}

# Create auth policy (scoped to exact KMS key)
resource "ibm_iam_authorization_policy" "kms_policy" {
  count                    = local.create_cross_account_auth_policy ? 1 : 0
  provider                 = ibm.kms
  source_service_account   = data.ibm_iam_account_settings.iam_account_settings[0].account_id
  source_service_name      = "secrets-manager"
  source_resource_group_id = module.resource_group[0].resource_group_id
  roles                    = ["Reader"]
  description              = "Allow all Secrets Manager instances in the resource group ${local.kms_account_id} to read the ${local.kms_service_name} key ${local.kms_key_id} from the instance GUID ${local.kms_instance_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service_name
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.kms_instance_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_id
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }

}
# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  count           = local.create_cross_account_auth_policy ? 1 : 0
  depends_on      = [ibm_iam_authorization_policy.kms_policy]
  create_duration = "30s"
}

# if using HPCS ,create a second IAM authorization that assigns the Viewer platform access in Hyper Protect Crypto Services .[Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-mng-data#using-byok)
resource "ibm_iam_authorization_policy" "secrets_manager_hpcs_policy" {
  count                       = local.create_cross_account_hpcs_auth_policy
  provider                    = ibm.kms
  source_service_account      = data.ibm_iam_account_settings.iam_account_settings[0].account_id
  source_service_name         = "secrets-manager"
  source_resource_group_id    = module.resource_group[0].resource_group_id
  target_service_name         = local.kms_service_name
  target_resource_instance_id = local.kms_instance_guid
  roles                       = ["Viewer"]
  description                 = "Allow all Secrets Manager instances in the resource group ${module.resource_group[0].resource_group_id} in the account ${local.kms_account_id} to view from the ${local.kms_service_name} instance GUID ${local.kms_instance_guid}"
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_sm_hpcs_authorization_policy" {
  count           = local.create_cross_account_hpcs_auth_policy
  depends_on      = [ibm_iam_authorization_policy.secrets_manager_hpcs_policy]
  create_duration = "30s"
}

# KMS root key for Secrets Manager secret encryption
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = var.existing_secrets_manager_crn == null && var.kms_encryption_enabled && var.existing_secrets_manager_kms_key_crn == null ? 1 : 0 # no need to create any KMS resources if passing an existing key
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "5.0.2"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name     = local.kms_key_ring_name
      existing_key_ring = false
      keys = [
        {
          key_name                 = local.kms_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true # Force delete must be set to true, or the terraform destroy will fail since the service does not de-register itself from the key until the reclamation period has expired.
        }
      ]
    }
  ]
}

########################################################################################################################
# Secrets Manager
########################################################################################################################

locals {
  parsed_existing_secrets_manager_crn = var.existing_secrets_manager_crn != null ? split(":", var.existing_secrets_manager_crn) : []
  secrets_manager_guid                = var.existing_secrets_manager_crn != null ? (length(local.parsed_existing_secrets_manager_crn) > 0 ? local.parsed_existing_secrets_manager_crn[7] : null) : module.secrets_manager.secrets_manager_guid
  secrets_manager_crn                 = var.existing_secrets_manager_crn != null ? var.existing_secrets_manager_crn : module.secrets_manager.secrets_manager_crn
  secrets_manager_region              = var.existing_secrets_manager_crn != null ? (length(local.parsed_existing_secrets_manager_crn) > 0 ? local.parsed_existing_secrets_manager_crn[5] : null) : module.secrets_manager.secrets_manager_region
  enable_event_notifications          = var.existing_event_notifications_instance_crn != null ? true : false
}

module "secrets_manager" {
  depends_on                    = [time_sleep.wait_for_authorization_policy]
  source                        = "../.."
  existing_sm_instance_crn      = var.existing_secrets_manager_crn
  resource_group_id             = module.resource_group.resource_group_id
  region                        = var.region
  secrets_manager_name          = "${local.prefix}${var.secrets_manager_instance_name}"
  sm_service_plan               = var.service_plan
  sm_tags                       = var.secrets_manager_resource_tags
  skip_iam_authorization_policy = var.skip_sm_ce_iam_authorization_policy
  # kms dependency
  is_hpcs_key                       = local.is_hpcs_key
  kms_encryption_enabled            = var.kms_encryption_enabled
  kms_key_crn                       = local.kms_key_crn
  skip_kms_iam_authorization_policy = var.skip_sm_kms_iam_authorization_policy || local.create_cross_account_auth_policy
  # event notifications dependency
  enable_event_notification        = local.enable_event_notifications
  existing_en_instance_crn         = var.existing_event_notifications_instance_crn
  skip_en_iam_authorization_policy = var.skip_event_notifications_iam_authorization_policy
  cbr_rules                        = var.secrets_manager_cbr_rules
  endpoint_type                    = var.secrets_manager_endpoint_type
  allowed_network                  = var.allowed_network
  secrets                          = var.secret_groups
}

data "ibm_resource_instance" "existing_sm" {
  count      = var.existing_secrets_manager_crn == null ? 0 : 1
  identifier = var.existing_secrets_manager_crn
}

#######################################################################################################################
# Secrets Manager Event Notifications Configuration
#######################################################################################################################

locals {
  parsed_existing_en_instance_crn = var.existing_event_notifications_instance_crn != null ? split(":", var.existing_event_notifications_instance_crn) : []
  existing_en_guid                = length(local.parsed_existing_en_instance_crn) > 0 ? local.parsed_existing_en_instance_crn[7] : null
}

data "ibm_en_destinations" "en_destinations" {
  # if existing SM instance CRN is passed (!= null), then never do data lookup for EN destinations
  count         = var.existing_secrets_manager_crn == null && local.enable_event_notifications ? 1 : 0
  instance_guid = local.existing_en_guid
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5533
resource "time_sleep" "wait_for_secrets_manager" {
  # if existing SM instance CRN is passed (!= null), then never work with EN
  count      = var.existing_secrets_manager_crn == null && local.enable_event_notifications ? 1 : 0
  depends_on = [module.secrets_manager]

  create_duration = "30s"
}

resource "ibm_en_topic" "en_topic" {
  # if existing SM instance CRN is passed (!= null), then never create EN topic
  count         = var.existing_secrets_manager_crn == null && local.enable_event_notifications ? 1 : 0
  depends_on    = [time_sleep.wait_for_secrets_manager]
  instance_guid = local.existing_en_guid
  name          = "Topic for SCC instance ${module.secrets_manager.secrets_manager_guid}"
  description   = "Topic for Secrets Manager events routing"
  sources {
    id = local.secrets_manager_crn
    rules {
      enabled           = true
      event_type_filter = "$.*"
    }
  }
}

resource "ibm_en_subscription_email" "email_subscription" {
  # if existing SM instance CRN is passed (!= null), then never create EN email subscription
  count          = var.existing_secrets_manager_crn == null && local.enable_event_notifications && length(var.event_notifications_email_list) > 0 ? 1 : 0
  instance_guid  = local.existing_en_guid
  name           = "Email for Secrets Manager Subscription"
  description    = "Subscription for Secret Manager Events"
  destination_id = [for s in toset(data.ibm_en_destinations.en_destinations[count.index].destinations) : s.id if s.type == "smtp_ibm"][0]
  topic_id       = ibm_en_topic.en_topic[count.index].topic_id
  attributes {
    add_notification_payload = true
    reply_to_mail            = var.event_notifications_reply_to_email
    reply_to_name            = "Secret Manager Event Notifications Bot"
    from_name                = var.event_notifications_from_email
    invited                  = var.event_notifications_email_list
  }
}
