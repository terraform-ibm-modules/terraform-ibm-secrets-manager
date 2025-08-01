##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Secrets Manager
##############################################################################

module "secrets_manager" {
  count                         = var.provision_secrets_manager == true ? 1 : 0
  source                        = "../.."
  resource_group_id             = module.resource_group.resource_group_id
  region                        = var.region
  secrets_manager_name          = "${var.prefix}-tsm"
  sm_service_plan               = "trial"
  skip_iam_authorization_policy = true
}
