provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "vault" {
  address                = data.ibm_sm_instance.vault.endpoints[0].public[0].vault_api
  token                  = ibm_sm_admin_token.vault.token
  namespace              = "admin" # customers administer the cluster from the `admin` namespace
  skip_child_token       = true    # the admin token is not renewable
  skip_get_vault_version = true
  vault_version_override = data.ibm_sm_instance.vault.vault_cluster[0].version
}
