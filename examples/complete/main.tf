module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "key_protect" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "4.21.3"
  key_protect_instance_name = "${var.prefix}-key-protect"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  keys = [
    {
      key_ring_name = "${var.prefix}-sm"
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
  version           = "1.19.4"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  region            = var.en_region
}

resource "ibm_iam_authorization_policy" "en_policy" {
  source_service_name         = "secrets-manager"
  roles                       = ["Key Manager"]
  target_service_name         = "event-notifications"
  target_resource_instance_id = module.event_notification.guid
  description                 = "Allow the Secret manager Key Manager role access to event-notifications with guid ${module.event_notification.guid}."
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
}

resource "time_sleep" "wait_for_en_policy" {
  depends_on      = [ibm_iam_authorization_policy.en_policy]
  create_duration = "30s"
}

module "secrets_manager" {
  depends_on                = [time_sleep.wait_for_en_policy]
  source                    = "../.."
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  secrets_manager_name      = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_service_plan           = var.sm_service_plan
  sm_tags                   = var.resource_tags
  kms_encryption_enabled    = true
  is_hpcs_key               = false
  kms_key_crn               = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].crn
  enable_event_notification = true
  existing_en_instance_crn  = module.event_notification.crn
  secrets = [
    {
      secret_group_name = "${var.prefix}-secret-group"
      secrets = [{
        secret_name             = "${var.prefix}-kp-key-crn"
        secret_type             = "arbitrary"
        secret_payload_password = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].crn
        },
        {
          # Arbitrary service credential for source service event notifications, with role Event-Notification-Publisher
          secret_name                                 = "${var.prefix}-service-credential"
          secret_type                                 = "service_credentials" #checkov:skip=CKV_SECRET_6
          secret_description                          = "Created by secrets-manager-module complete example"
          service_credentials_source_service_crn      = module.event_notification.crn
          service_credentials_source_service_role_crn = "crn:v1:bluemix:public:event-notifications::::serviceRole:Event-Notification-Publisher"
        }
      ]
    },
    {
      secret_group_name     = "default"
      existing_secret_group = true
      secrets = [{
        secret_name             = "${var.prefix}-kp-key-id"
        secret_type             = "arbitrary"
        secret_payload_password = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].key_id
        }
      ]
    }
  ]
}
