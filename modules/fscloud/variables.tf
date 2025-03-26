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

variable "existing_sm_instance_crn" {
  type        = string
  description = "The CRN of an existing Secrets Manager instance. If not supplied, a new instance is created."
  default     = null
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to skip the creation of the IAM authorization policies required to enable the IAM credentials engine. If set to false, policies will be created that grants the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manage' access to the IAM groups service."
  default     = false
}

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_crn` variable. If a value is specified for `ibmcloud_kms_api_key`, the policy is created in the KMS account."
  default     = false
}

##############################################################################
# Key Management Service (KMS)
##############################################################################
variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of Key Management Service (KMS) key that you want to use for encryption."
}

variable "is_hpcs_key" {
  type        = bool
  description = "Set to true if the key is hpcs, otherwise false."
  default     = false
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
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "(list) List of CBR rules to create"
  default     = []
  # Validation happens in the rule module
}

##############################################################
# Secrets
##############################################################

variable "secrets" {
  type = list(object({
    secret_group_name        = string
    secret_group_description = optional(string)
    existing_secret_group    = optional(bool, false)
    secrets = optional(list(object({
      secret_name                                 = string
      secret_description                          = optional(string)
      secret_type                                 = optional(string)
      imported_cert_certificate                   = optional(string)
      imported_cert_private_key                   = optional(string)
      imported_cert_intermediate                  = optional(string)
      secret_username                             = optional(string)
      secret_labels                               = optional(list(string), [])
      secret_payload_password                     = optional(string, "")
      secret_auto_rotation                        = optional(bool, true)
      secret_auto_rotation_unit                   = optional(string, "day")
      secret_auto_rotation_interval               = optional(number, 89)
      service_credentials_ttl                     = optional(string, "7776000") # 90 days
      service_credentials_source_service_crn      = optional(string)
      service_credentials_source_service_role_crn = optional(string)
    })))
  }))
  description = "Secret Manager secrets configurations."
  default     = []
}
