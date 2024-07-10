module "secrets_manager" {
  source                           = "../.."
  resource_group_id                = var.resource_group_id
  region                           = var.region
  secrets_manager_name             = var.secrets_manager_name #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_service_plan                  = var.service_plan
  sm_tags                          = var.sm_tags
  allowed_network                  = "private-only"
  endpoint_type                    = "private"
  kms_encryption_enabled           = true
  existing_kms_instance_guid       = var.existing_kms_instance_guid
  enable_event_notification        = var.enable_event_notification
  existing_en_instance_crn         = var.existing_en_instance_crn
  skip_en_iam_authorization_policy = var.skip_en_iam_authorization_policy
  kms_key_crn                      = var.kms_key_crn
  cbr_rules                        = var.cbr_rules
  secrets                          = var.secrets
}
