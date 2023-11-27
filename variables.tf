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

variable "sm_service_plan" {
  type        = string
  description = "The Secrets Manager plan to provision."
  default     = "standard"
  validation {
    condition     = contains(["standard", "trial"], var.sm_service_plan)
    error_message = "The specified sm_service_plan is not a valid selection!"
  }
}

variable "sm_tags" {
  type        = list(string)
  description = "The list of resource tags that you want to associate with your Secrets Manager instance."
  default     = []
}

variable "service_endpoints" {
  type        = string
  description = "The types of service endpoints to set on the Secrets Manager instance. Possible values are `public`, `private` or `public-and-private`."
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection!"
  }
}

variable "kms_encryption_enabled" {
  type        = bool
  description = "Set this to true to control the encryption keys used to encrypt the data that you store in Secrets Manager. If set to false, the data that you store is encrypted at rest by using envelope encryption. For more details, see https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-mng-data&interface=ui#about-encryption."
  default     = false
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_guid` variable. In addition, no policy is created if `kms_encryption_enabled` is set to false."
  default     = false
}

variable "existing_kms_instance_guid" {
  type        = string
  description = "The GUID of the Hyper Protect Crypto Services or Key Protect instance in which the key specified in `kms_key_crn` is coming from. Required only if `kms_encryption_enabled` is set to true, and `skip_iam_authorization_policy` is set to false."
  default     = null
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of a Key Management Service like Key Protect or Hyper Protect Crypto Services (HPCS) that you want to use for encryption. Only used if `kms_encryption_enabled` is set to true."
  default     = null
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
  }))
  description = "(Optional, list) List of CBR rules to create"
  default     = []
  # Validation happens in the rule module
}
