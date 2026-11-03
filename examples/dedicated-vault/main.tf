module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Vault Dedicated instance (IBM Cloud control plane)
#
# The `dedicated` plan is a Vault Enterprise cluster. It does not expose the Secrets Manager API
# so the `secrets` input of the module can not be used. The public endpoint is required for the
# Vault provider to reach the cluster from where Terraform runs.
##############################################################################

module "secrets_manager" {
  source               = "../.."
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  secrets_manager_name = "${var.prefix}-secrets-manager" #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_service_plan      = "dedicated"
  allowed_network      = "public-and-private"
  resource_tags        = var.resource_tags
}

data "ibm_sm_instance" "vault" {
  instance_id = module.secrets_manager.secrets_manager_guid
}

# 1 hour, non-renewable admin token (automatically refreshed by the provider when about to expire)
resource "ibm_sm_admin_token" "vault" {
  instance_id = module.secrets_manager.secrets_manager_guid
}

##############################################################################
# Vault configuration (HashiCorp Vault provider)
##############################################################################

resource "vault_mount" "kv" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "example" {
  mount = vault_mount.kv.path
  name  = "${var.prefix}/example"
  data_json = jsonencode({
    example_key = "example_value"
  })
}
