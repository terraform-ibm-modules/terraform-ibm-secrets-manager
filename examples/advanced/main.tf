##############################################################################
# Resource group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.8"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect instance and root key
##############################################################################

module "key_protect" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "5.5.33"
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

##############################################################################
# Event Notifications
##############################################################################

module "event_notifications" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "2.11.22"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  region            = var.en_region
}

# s2s auth policy required for Secrets Manager to manage Event Notifications service credentials
resource "ibm_iam_authorization_policy" "en_policy" {
  source_service_name         = "secrets-manager"
  roles                       = ["Key Manager"]
  target_service_name         = "event-notifications"
  target_resource_instance_id = module.event_notifications.guid
  description                 = "Grant Secret Manager a 'Key Manager' role to the Event Notifications instance ${module.event_notifications.guid} for managing service credentials."
  lifecycle {
    create_before_destroy = true
  }
}

resource "time_sleep" "wait_for_en_policy" {
  depends_on      = [ibm_iam_authorization_policy.en_policy]
  create_duration = "30s"
}

##############################################################################
# Secrets Manager
##############################################################################

locals {
  secret_name_service_credential = "${var.prefix}-service-credential"
  secret_name_arbitrary_example  = "${var.prefix}-arbitrary-example"
  secret_name_kp_key_id          = "${var.prefix}-kp-key-id"
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
  existing_en_instance_crn  = module.event_notifications.crn
  secrets = [
    # Example creating new secrets group with secrets in it
    {
      secret_group_name = "${var.prefix}-secret-group"
      secrets = [
        # Example creating Event Notifications service credential secret
        {
          secret_name                                 = local.secret_name_service_credential
          secret_type                                 = "service_credentials" #checkov:skip=CKV_SECRET_6
          secret_description                          = "Created by secrets-manager-module advanced example"
          service_credentials_source_service_crn      = module.event_notifications.crn
          service_credentials_source_service_role_crn = "crn:v1:bluemix:public:event-notifications::::serviceRole:Event-Notification-Publisher"
        },
        # Example creating arbitrary secret
        {
          secret_name             = local.secret_name_arbitrary_example
          secret_type             = "arbitrary"
          secret_payload_password = var.ibmcloud_api_key
        }
      ]
    },
    # Example creating secret in existing secret group
    {
      secret_group_name     = "default"
      existing_secret_group = true
      secrets = [{
        secret_name             = local.secret_name_kp_key_id
        secret_type             = "arbitrary"
        secret_payload_password = module.key_protect.keys["${var.prefix}-sm.${var.prefix}-sm-key"].key_id
        }
      ]
    }
  ]
}

##############################################################################
# Code Engine configuration
# (required to use create a custom credential)
##############################################################################

# Create new code engine project
module "code_engine_project" {
  source            = "terraform-ibm-modules/code-engine/ibm//modules/project"
  version           = "4.7.30"
  name              = "${var.prefix}-project"
  resource_group_id = module.resource_group.resource_group_id
}

# Create new code engine secret
locals {
  registry_hostname = "private.de.icr.io"
  output_image      = "${local.registry_hostname}/${resource.ibm_cr_namespace.rg_namespace.name}/custom-engine-job"
}

module "code_engine_secret" {
  source     = "terraform-ibm-modules/code-engine/ibm//modules/secret"
  version    = "4.7.30"
  name       = "${var.prefix}-rs"
  project_id = module.code_engine_project.id
  format     = "registry"
  data = {
    "server"   = local.registry_hostname,
    "username" = "iamapikey",
    "password" = var.ibmcloud_api_key,
  }
}

# Create new Container Registry namespace
resource "ibm_cr_namespace" "rg_namespace" {
  name              = "${var.prefix}-crn"
  resource_group_id = module.resource_group.resource_group_id
}

# Build example Go application in Code Engine project which dynamically generates User IBM Cloud IAM API Keys
module "code_engine_build" {
  source                     = "terraform-ibm-modules/code-engine/ibm//modules/build"
  version                    = "4.7.30"
  name                       = "${var.prefix}-build"
  region                     = var.region
  ibmcloud_api_key           = var.ibmcloud_api_key
  project_id                 = module.code_engine_project.id
  existing_resource_group_id = module.resource_group.resource_group_id
  source_url                 = "https://github.com/IBM/secrets-manager-custom-credentials-providers"
  source_context_dir         = "ibmcloud-iam-user-apikey-provider-go"
  strategy_type              = "dockerfile"
  output_secret              = module.code_engine_secret.name
  output_image               = local.output_image
}

# Pull the sample job config from github
data "http" "job_config" {
  url = "https://raw.githubusercontent.com/IBM/secrets-manager-custom-credentials-providers/refs/heads/main/ibmcloud-iam-user-apikey-provider-go/job_config.json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  job_env_variables = jsondecode(data.http.job_config.response_body).job_env_variables
}

# Run the Code Engine job
module "code_engine_job" {
  depends_on      = [module.code_engine_build]
  source          = "terraform-ibm-modules/code-engine/ibm//modules/job"
  version         = "4.7.30"
  name            = "${var.prefix}-job"
  image_reference = local.output_image
  image_secret    = module.code_engine_secret.name
  project_id      = module.code_engine_project.id
  run_env_variables = [
    for env_var in local.job_env_variables : {
      type  = "literal"
      name  = env_var.name
      value = tostring(env_var.value)
    }
  ]
}

##############################################################################
# Create Custom Credential engine
##############################################################################

module "custom_credential_engine" {
  depends_on                    = [module.secrets_manager, module.code_engine_job]
  source                        = "terraform-ibm-modules/secrets-manager-custom-credentials-engine/ibm"
  version                       = "1.1.3"
  secrets_manager_guid          = module.secrets_manager.secrets_manager_guid
  secrets_manager_region        = module.secrets_manager.secrets_manager_region
  custom_credential_engine_name = "${var.prefix}-test-custom-engine"
  endpoint_type                 = "public"
  code_engine_project_id        = module.code_engine_project.project_id
  code_engine_job_name          = module.code_engine_job.name
  code_engine_region            = var.region
  task_timeout                  = "10m"
  service_id_name               = "${var.prefix}-test-service-id"
  iam_credential_secret_name    = "${var.prefix}-test-iam-secret"
}

##############################################################################
# Create Custom Credential secret
# (using secrets-manager-secret to create the custom credential secret as it
#  can only be done after the Custom Credential engine is configured)
##############################################################################

module "secret_manager_custom_credential" {
  depends_on                        = [module.secrets_manager, module.custom_credential_engine]
  source                            = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                           = "1.9.14"
  secret_type                       = "custom_credentials" #checkov:skip=CKV_SECRET_6
  region                            = module.secrets_manager.secrets_manager_region
  secrets_manager_guid              = module.secrets_manager.secrets_manager_guid
  secret_name                       = "${var.prefix}-custom-credentials"
  secret_description                = "created by secrets-manager module complete example"
  custom_credentials_configurations = module.custom_credential_engine.custom_config_engine_name
  custom_metadata                   = { "metadata_custom_key" : "metadata_custom_value" } # can add any custom metadata here
  custom_credentials_parameters     = true
  job_parameters = {
    string_values = {
      apikey_secret_id = module.secrets_manager.secrets[local.secret_name_service_credential].secret_id
    }
  }
}
