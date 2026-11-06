terraform {
  required_version = ">= v1.9.0"

  # `ibm_sm_instance` and `ibm_sm_admin_token` are only available in the IBM provider from version 2.6.0
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 2.8.3"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.13.0"
    }
  }
}
