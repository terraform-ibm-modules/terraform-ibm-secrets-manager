variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API token this account authenticates to"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for sm instance"
  default     = "secrets-manager-test"
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "us-east"
}

variable "resource_group_name" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

##############################################################################
# Event Notification (EN)
##############################################################################

variable "en_region" {
  type        = string
  description = "Region where event notification will be created"
  default     = "au-syd"
}

##############################################################################
# Key Management Service (KMS)
##############################################################################

variable "existing_kms_instance_guid" {
  type        = string
  description = "The GUID of the Hyper Protect Crypto Services or Key Protect instance in which the key specified in `kms_key_crn` is coming from. Required only if `kms_encryption_enabled` is set to true, and `skip_kms_iam_authorization_policy` is set to false."
  default     = null
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of a Key Management Service like Key Protect or Hyper Protect Crypto Services (HPCS) that you want to use for encryption. Only used if `kms_encryption_enabled` is set to true."
  default     = null
}
