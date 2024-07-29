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

module "icd_elasticsearch" {
  source            = "terraform-ibm-modules/icd-elasticsearch/ibm"
  version           = "1.14.5"
  resource_group_id = module.resource_group.resource_group_id
  name              = "dishank-test"
  region            = var.region
}

resource "ibm_iam_authorization_policy" "policy" {
  depends_on                  = [module.icd_elasticsearch]
  source_service_name         = "secrets-manager"
  source_resource_group_id    = module.resource_group.resource_group_id
  target_service_name         = "databases-for-elasticsearch"
  target_resource_instance_id = module.icd_elasticsearch.id
  roles                       = ["Key Manager"]
}

resource "time_sleep" "wait_for_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.policy]
  create_duration = "30s"
}

module "secrets_manager" {
  depends_on                 = [time_sleep.wait_for_authorization_policy]
  source                     = "../.."
  resource_group_id          = module.resource_group.resource_group_id
  region                     = var.region
  secrets_manager_name       = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_service_plan            = var.sm_service_plan
  sm_tags                    = var.resource_tags
  kms_encryption_enabled     = true
  existing_kms_instance_guid = module.key_protect.kms_guid
  kms_key_crn                = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].crn
  enable_event_notification  = true
  existing_en_instance_crn   = module.event_notification.crn
  secrets = [
    {
      secret_group_name = "${var.prefix}-secret-group" #checkov:skip=CKV_SECRET_6
      secrets = [{
        secret_name             = "${var.prefix}-kp-key-crn"
        secret_type             = "arbitrary"
        secret_payload_password = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].crn
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
      }, {
      secret_group_name = "test-dishank" #checkov:skip=CKV_SECRET_6
      secrets = [{
        secret_name                             = "dishank-cred-1"
        service_credentials_source_service_role = "Editor"
        secret_type                             = "service_credentials" # checkov:skip=CKV_SECRET_6
        service_credentials_source_service_crn  = module.icd_elasticsearch.id
        }, {
        secret_name                             = "dishank-cred-2"
        service_credentials_source_service_role = "Editor"
        secret_type                             = "service_credentials" # checkov:skip=CKV_SECRET_6
        service_credentials_source_service_crn  = module.icd_elasticsearch.id
      }]
    }
  ]
}
