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

variable "service_plan" {
  type        = string
  description = "The Secrets Manager plan to provision."
  default     = "standard"
}

variable "sm_tags" {
  type        = list(string)
  description = "The list of resource tags that you want to associate with your Secrets Manager instance."
  default     = []
}

variable "iam_engine_enabled" {
  type        = bool
  description = "Set this to true to to configure an IBM Secrets Manager IAM credentials engine for an existing IBM Secrets Manager instance. If set to false, no iam engine will be configured for your secrets manager instance. For more details, see https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-configure-iam-engine."
  default     = false
}

variable "iam_engine_name" {
  type        = string
  description = "The name of the IAM Engine used to configure an IBM Secrets Manager IAM credentials engine for an existing IBM Secrets Manager instance."
  default     = null
}

##############################################################################
# Key Management Service (KMS)
##############################################################################

variable "existing_kms_instance_guid" {
  type        = string
  description = "The GUID of the Hyper Protect Crypto Services instance in which the key specified in `kms_key_crn` is coming from."
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of Hyper Protect Crypto Services (HPCS) that you want to use for encryption."

  validation {
    condition     = can(regex(".*hs-crypto.*", var.kms_key_crn))
    error_message = "Variable 'kms_key_crn' must be a Hyper Protect Crypto Services (HPCS) key CRN."
  }
}

##############################################################################
# Event Notification
##############################################################################

variable "skip_en_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances (scoped to the resource group) an 'Event Source Manager' role to the given Event Notifications instance passed in the `existing_en_instance_crn` input variable. In addition, no policy is created if `enable_event_notification` is set to false."
  default     = false
}

variable "enable_event_notification" {
  type        = bool
  default     = false
  description = "Set this to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When setting this to true, a value must be passed for `existing_en_instance_crn` variable."
}

variable "existing_en_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance."
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
  description = "(list) List of CBR rules to create"
  default     = []
  # Validation happens in the rule module
}
