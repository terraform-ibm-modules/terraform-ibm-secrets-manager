module "secrets_manager" {
  source                                            = "../fully-configurable"
  ibmcloud_api_key                                  = var.ibmcloud_api_key
  existing_resource_group_name                      = var.existing_resource_group_name
  prefix                                            = var.prefix
  provider_visibility                               = "private"
  region                                            = var.region
  secrets_manager_instance_name                     = var.secrets_manager_instance_name
  existing_secrets_manager_crn                      = var.existing_secrets_manager_crn
  service_plan                                      = var.service_plan
  skip_sm_ce_iam_authorization_policy               = var.skip_sm_ce_iam_authorization_policy
  secrets_manager_resource_tags                     = var.secrets_manager_resource_tags
  secrets_manager_endpoint_type                     = "private"
  allowed_network                                   = "private-only"
  skip_sm_kms_iam_authorization_policy              = var.skip_sm_kms_iam_authorization_policy
  existing_secrets_manager_kms_key_crn              = var.existing_secrets_manager_kms_key_crn
  kms_encryption_enabled                            = true
  existing_kms_instance_crn                         = var.existing_kms_instance_crn
  kms_endpoint_type                                 = "private"
  kms_key_ring_name                                 = var.kms_key_ring_name
  kms_key_name                                      = var.kms_key_name
  ibmcloud_kms_api_key                              = var.ibmcloud_kms_api_key
  existing_event_notifications_instance_crn         = var.existing_event_notifications_instance_crn
  skip_event_notifications_iam_authorization_policy = var.skip_event_notifications_iam_authorization_policy
  event_notifications_email_list                    = var.event_notifications_email_list
  event_notifications_from_email                    = var.event_notifications_from_email
  event_notifications_reply_to_email                = var.event_notifications_reply_to_email
  secrets_manager_cbr_rules                         = var.secrets_manager_cbr_rules
  secret_groups                                     = var.secret_groups
}
