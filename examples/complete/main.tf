module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.3.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "key_protect" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "5.1.24"
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

resource "ibm_iam_api_key" "api_key" {
  name        = "${var.prefix}-api-key"
  description = "created for secrets-manager-secret complete example"
}

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "2.6.24"
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
        },
        {
          secret_name             = "${var.prefix}-custom-service-credential"
          secret_type             = "arbitrary"
          secret_payload_password = ibm_iam_api_key.api_key.apikey
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

##############################################################################
# Code Engine Project
##############################################################################
module "code_engine_project" {
  source            = "terraform-ibm-modules/code-engine/ibm//modules/project"
  version           = "4.5.8"
  name              = "${var.prefix}-project"
  resource_group_id = module.resource_group.resource_group_id
}

##############################################################################
# Code Engine Secret
##############################################################################
module "code_engine_secret" {
  source     = "terraform-ibm-modules/code-engine/ibm//modules/secret"
  version    = "4.5.8"
  name       = "${var.prefix}-rs"
  project_id = module.code_engine_project.id
  format     = "registry"
  data = {
    "server"   = "private.de.icr.io",
    "username" = "iamapikey",
    "password" = var.ibmcloud_api_key,
  }
}

##############################################################################
# Container Registry Namespace
##############################################################################
resource "ibm_cr_namespace" "rg_namespace" {
  name              = "${var.prefix}-crn"
  resource_group_id = module.resource_group.resource_group_id
}

##############################################################################
# Code Engine Build
##############################################################################
locals {
  output_image = "private.de.icr.io/${resource.ibm_cr_namespace.rg_namespace.name}/custom-engine-job"
}

# For example the region is hardcoded to us-south in order to hardcode the output image and region for creating Code Engine Project and build
module "code_engine_build" {
  source                     = "terraform-ibm-modules/code-engine/ibm//modules/build"
  version                    = "4.5.8"
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

##############################################################################
# Code Engine Job
##############################################################################

data "http" "job_config" {
  url = "https://raw.githubusercontent.com/IBM/secrets-manager-custom-credentials-providers/refs/heads/main/ibmcloud-iam-user-apikey-provider-go/job_config.json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  job_env_variables = jsondecode(data.http.job_config.response_body).job_env_variables
}

module "code_engine_job" {
  depends_on      = [module.code_engine_build]
  source          = "terraform-ibm-modules/code-engine/ibm//modules/job"
  version         = "4.5.8"
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
# Custom Credential Engine and secret
##############################################################################

module "custom_credential_engine" {
  depends_on                    = [module.secrets_manager, module.code_engine_job]
  source                        = "terraform-ibm-modules/secrets-manager-custom-credentials-engine/ibm"
  version                       = "1.0.0"
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

# Currently the main module cannot be called again as some of the count for resources depends on a computable input existing_en_instance_crn which will give error if the value is not available during planning
# As a workaround the secret manager secret is directly being created via module call
module "secret_manager_custom_credential" {
  depends_on                        = [module.secrets_manager, module.custom_credential_engine]
  source                            = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                           = "1.9.0"
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
      apikey_secret_id = module.secrets_manager.secrets["${var.prefix}-custom-service-credential"].secret_id
    }
  }
}
