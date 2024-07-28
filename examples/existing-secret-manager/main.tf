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


locals {
  service_credentials_secrets = [
    for service_credentials_secret in var.service_credentials_secrets : {
      secret_group_name        = service_credentials_secret.secret_group_name
      secret_group_description = service_credentials_secret.secret_group_description
      existing_secret_group    = service_credentials_secret.existing_secret_group
      secrets = [
        for secret in service_credentials_secret.service_credentials : {
          secret_name                             = secret.secret_name
          secret_labels                           = secret.secret_labels
          secret_auto_rotation                    = secret.secret_auto_rotation
          secret_auto_rotation_unit               = secret.secret_auto_rotation_unit
          secret_auto_rotation_interval           = secret.secret_auto_rotation_interval
          service_credentials_ttl                 = secret.service_credentials_ttl
          service_credential_secret_description   = secret.service_credential_secret_description
          service_credentials_source_service_role = secret.service_credentials_source_service_role
          service_credentials_source_service_crn  = "crn:v1:bluemix:public:cloud-object-storage:global:a/abac0df06b644a9cabc6e44f55b3880e:958bb025-c745-4ef4-b869-4cd30784929d::"
          # checkov:skip=CKV_SECRET_6

          secret_type = "service_credentials" # checkov:skip=CKV_SECRET_6
        }
      ]
    }
  ]

  existing_secrets_manager_instance_crn_split = var.existing_sm_instance_crn != null ? split(":", var.existing_sm_instance_crn) : null
  existing_secrets_manager_instance_guid      = var.existing_sm_instance_crn != null ? element(local.existing_secrets_manager_instance_crn_split, length(local.existing_secrets_manager_instance_crn_split) - 3) : null
  existing_secrets_manager_instance_region    = var.existing_sm_instance_crn != null ? element(local.existing_secrets_manager_instance_crn_split, length(local.existing_secrets_manager_instance_crn_split) - 5) : null
}

module "secrets_manager_service_credentails" {
  source                      = "../../modules/secrets"
  existing_sm_instance_guid   = local.existing_secrets_manager_instance_guid
  existing_sm_instance_region = local.existing_secrets_manager_instance_region
  endpoint_type               = "public"
  secrets                     = local.service_credentials_secrets
}
