##############################################################################
# Input Variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group to provision the Secrets Manager instance to."
}

variable "region" {
  type        = string
  description = "The region to provision the Secrets Manager instance to."
}

variable "secrets_manager_name" {
  type        = string
  description = "The name to give the Secrets Manager instance."
}

variable "sm_tags" {
  type        = list(string)
  description = "The list of resource tags that you want to associate with your Secrets Manager instance."
  default     = []
}

variable "existing_kms_instance_guid" {
  type        = string
  description = "The GUID of the Hyper Protect Crypto Services or Key Protect instance in which the key specified in `kms_key_crn` is coming from. Required only if `kms_encryption_enabled` is set to true, and `skip_kms_iam_authorization_policy` is set to false."
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of a Key Management Service like Key Protect or Hyper Protect Crypto Services (HPCS) that you want to use for encryption. Only used if `kms_encryption_enabled` is set to true."
}

##############################################################################
# Event Notification
##############################################################################

variable "existing_en_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance."
}

##############################################################################
# Input Variables for Financial Services
##############################################################################

variable "vpc_crn" {
  description = "CRN of existing VPN"
  type        = string
}

variable "cbr_zone_name" {
  description = "The name given to the CBR zone"
  type        = string
}
