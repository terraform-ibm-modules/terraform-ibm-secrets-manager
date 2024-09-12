##############################################################################
# Input Variables
##############################################################################
variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group"
}

variable "region" {
  type        = string
  description = "The region where the resource will be provisioned.Its not required if passing a value for `existing_sm_instance_crn`."
  default     = null
}

variable "secrets_manager_name" {
  type        = string
  description = "The name of the Secrets Manager instance to create"
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

variable "allowed_network" {
  type        = string
  description = "The types of service endpoints to set on the Secrets Manager instance. Possible values are `private-only` or `public-and-private`."
  default     = "public-and-private"
  validation {
    condition     = contains(["private-only", "public-and-private"], var.allowed_network)
    error_message = "The specified allowed_network is not a valid selection!"
  }
}

variable "kms_encryption_enabled" {
  type        = bool
  description = "Set this to true to control the encryption keys used to encrypt the data that you store in Secrets Manager. If set to false, the data that you store is encrypted at rest by using envelope encryption. For more details, see https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-mng-data&interface=ui#about-encryption."
  default     = false
}

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_guid` variable. In addition, no policy is created if `kms_encryption_enabled` is set to false."
  default     = false
}

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

variable "existing_sm_instance_crn" {
  type        = string
  description = "An existing Secrets Manager instance CRN. If not provided an new instance will be provisioned."
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
  description = "Set this to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When setting this to true, a value must be passed for `existing_en_instance_crn` and `existing_sm_instance_crn` must be null."
}

variable "existing_en_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance."
}

variable "endpoint_type" {
  type        = string
  description = "The type of endpoint (public or private) to connect to the Secrets Manager API. The Terraform provider uses this endpoint type to interact with the Secrets Manager API and configure Event Notifications."
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.endpoint_type)
    error_message = "The specified endpoint_type is not a valid selection!"
  }
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
      secret_name                             = string
      secret_description                      = optional(string)
      secret_type                             = optional(string)
      imported_cert_certificate               = optional(string)
      imported_cert_private_key               = optional(string)
      imported_cert_intermediate              = optional(string)
      secret_username                         = optional(string)
      secret_labels                           = optional(list(string), [])
      secret_payload_password                 = optional(string, "")
      secret_auto_rotation                    = optional(bool, true)
      secret_auto_rotation_unit               = optional(string, "day")
      secret_auto_rotation_interval           = optional(number, 89)
      service_credentials_ttl                 = optional(string, "7776000") # 90 days
      service_credentials_source_service_crn  = optional(string)
      service_credentials_source_service_role = optional(string)
    })))
  }))
  description = "Secret Manager secrets configurations."
  default     = []
}
