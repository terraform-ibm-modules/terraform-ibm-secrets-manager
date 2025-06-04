provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  visibility       = local.effective_provider_visibility
}
provider "ibm" {
  alias            = "kms"
  ibmcloud_api_key = var.ibmcloud_kms_api_key != null ? var.ibmcloud_kms_api_key : var.ibmcloud_api_key
  region           = local.kms_region
  visibility       = local.effective_provider_visibility
}
