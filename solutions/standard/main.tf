########################################################################################################################
# Resource Group
########################################################################################################################
locals {
  # tflint-ignore: terraform_unused_declarations
  validate_resource_group = (var.existing_secrets_manager_crn == null && var.resource_group_name == null) ? tobool("Resource group name can not be null if existing secrets manager CRN is not set.") : true
}

module "resource_group" {
  count                        = var.existing_secrets_manager_crn == null ? 1 : 0
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.4"
  resource_group_name          = var.use_existing_resource_group == false ? (var.prefix != null ? "${var.prefix}-${var.resource_group_name}" : var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}

#######################################################################################################################
# KMS Key
#######################################################################################################################
locals {
  kms_key_crn       = var.existing_secrets_manager_crn == null ? (var.existing_secrets_manager_kms_key_crn != null ? var.existing_secrets_manager_kms_key_crn : module.kms[0].keys[format("%s.%s", local.kms_key_ring_name, local.kms_key_name)].crn) : null
  kms_key_ring_name = var.prefix != null ? "${var.prefix}-${var.kms_key_ring_name}" : var.kms_key_ring_name
  kms_key_name      = var.prefix != null ? "${var.prefix}-${var.kms_key_name}" : var.kms_key_name

  parsed_existing_kms_instance_crn = var.existing_kms_instance_crn != null ? split(":", var.existing_kms_instance_crn) : []
  kms_region                       = length(local.parsed_existing_kms_instance_crn) > 0 ? local.parsed_existing_kms_instance_crn[5] : null
  existing_kms_guid                = length(local.parsed_existing_kms_instance_crn) > 0 ? local.parsed_existing_kms_instance_crn[7] : null
}

# KMS root key for Secrets Manager secret encryption
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = var.existing_secrets_manager_crn != null || var.existing_secrets_manager_kms_key_crn != null ? 0 : 1 # no need to create any KMS resources if passing an existing key, or bucket
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.9.1"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_guid  = local.existing_kms_guid
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name         = local.kms_key_ring_name
      existing_key_ring     = false
      force_delete_key_ring = true
      keys = [
        {
          key_name                 = local.kms_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
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
  secrets_manager_guid                = var.existing_secrets_manager_crn != null ? (length(local.parsed_existing_secrets_manager_crn) > 0 ? local.parsed_existing_secrets_manager_crn[7] : null) : module.secrets_manager[0].secrets_manager_guid
  secrets_manager_crn                 = var.existing_secrets_manager_crn != null ? var.existing_secrets_manager_crn : module.secrets_manager[0].secrets_manager_crn
  secrets_manager_region              = var.existing_secrets_manager_crn != null ? (length(local.parsed_existing_secrets_manager_crn) > 0 ? local.parsed_existing_secrets_manager_crn[5] : null) : module.secrets_manager[0].secrets_manager_region
}

module "secrets_manager" {
  count                = var.existing_secrets_manager_crn != null ? 0 : 1
  source               = "../.."
  resource_group_id    = module.resource_group[0].resource_group_id
  region               = var.region
  secrets_manager_name = var.prefix != null ? "${var.prefix}-${var.secrets_manager_instance_name}" : var.secrets_manager_instance_name
  sm_service_plan      = var.service_plan
  allowed_network      = var.allowed_network
  sm_tags              = var.secret_manager_tags
  # kms dependency
  kms_encryption_enabled            = true
  existing_kms_instance_guid        = local.existing_kms_guid
  kms_key_crn                       = local.kms_key_crn
  skip_kms_iam_authorization_policy = var.skip_kms_iam_authorization_policy
  # event notifications dependency
  enable_event_notification        = var.existing_event_notification_instance_crn != null ? true : false
  existing_en_instance_crn         = var.existing_event_notification_instance_crn
  skip_en_iam_authorization_policy = var.skip_event_notification_iam_authorization_policy
  endpoint_type                    = var.allowed_network == "private-only" ? "private" : "public"
}

# Configure an IBM Secrets Manager IAM credentials engine for an existing IBM Secrets Manager instance.
module "iam_secrets_engine" {
  count                = var.iam_engine_enabled ? 1 : 0
  source               = "terraform-ibm-modules/secrets-manager-iam-engine/ibm"
  version              = "1.1.0"
  region               = local.secrets_manager_region
  iam_engine_name      = var.prefix != null ? "${var.prefix}-${var.iam_engine_name}" : var.iam_engine_name
  secrets_manager_guid = local.secrets_manager_guid
  endpoint_type        = var.allowed_network == "private-only" ? "private" : "public"
}

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_public_secret_engine = var.public_engine_enabled && var.public_engine_name == null ? tobool("When setting var.public_engine_enabled to true, a value must be passed for var.public_engine_name") : true
  # tflint-ignore: terraform_unused_declarations
  validate_private_secret_engine = var.private_engine_enabled && var.private_engine_name == null ? tobool("When setting var.private_engine_enabled to true, a value must be passed for var.private_engine_name") : true
}

# Configure an IBM Secrets Manager public certificate engine for an existing IBM Secrets Manager instance.
module "secrets_manager_public_cert_engine" {
  count   = var.public_engine_enabled ? 1 : 0
  source  = "terraform-ibm-modules/secrets-manager-public-cert-engine/ibm"
  version = "1.0.0"
  providers = {
    ibm              = ibm
    ibm.secret-store = ibm
  }
  secrets_manager_guid         = local.secrets_manager_guid
  region                       = local.secrets_manager_region
  internet_services_crn        = var.cis_id
  ibmcloud_cis_api_key         = var.ibmcloud_api_key
  dns_config_name              = var.dns_provider_name
  ca_config_name               = var.ca_name
  acme_letsencrypt_private_key = var.acme_letsencrypt_private_key
  service_endpoints            = var.allowed_network == "private-only" ? "private" : "public"
}


# Configure an IBM Secrets Manager private certificate engine for an existing IBM Secrets Manager instance.
module "private_secret_engine" {
  count                     = var.private_engine_enabled ? 1 : 0
  source                    = "terraform-ibm-modules/secrets-manager-private-cert-engine/ibm"
  version                   = "1.3.0"
  secrets_manager_guid      = local.secrets_manager_guid
  region                    = var.region
  root_ca_name              = var.root_ca_name
  root_ca_common_name       = var.root_ca_common_name
  root_ca_max_ttl           = var.root_ca_max_ttl
  intermediate_ca_name      = var.intermediate_ca_name
  certificate_template_name = var.certificate_template_name
  endpoint_type             = var.allowed_network == "private-only" ? "private" : "public"
}

data "ibm_resource_instance" "existing_sm" {
  count      = var.existing_secrets_manager_crn == null ? 0 : 1
  identifier = var.existing_secrets_manager_crn
}
