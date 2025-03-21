variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API token this account authenticates to"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for sm instance"
  default     = "sm-fsc"
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "au-syd"
}

variable "resource_group" {
  type        = string
  description = "A resource group name to use for this example, if `existing_resource_group` is false a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

##############################################################################
# Key Management Service (KMS)
##############################################################################

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of Hyper Protect Crypto Services (HPCS) that you want to use for encryption."
}
