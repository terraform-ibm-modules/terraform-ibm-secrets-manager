provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "ibm" {
  alias            = "kms"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.existing_kms_region
}
