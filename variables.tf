##############################################################################
# Input Variables
##############################################################################
variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group that contains the Secrets Manager instance."
}

variable "region" {
  type        = string
  description = "The region where the instance is created. Not required if passing a value for `existing_sm_instance_crn`."
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
    condition     = var.existing_sm_instance_crn == null ? contains(["standard", "trial"], var.sm_service_plan) : true
    error_message = "The specified `sm_service_plan` is not valid. Possible values are `standard` or `trial`."
  }
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to skip creating the IAM authorization policies that are required to enable the IAM credentials engine. If set to `false`, policies are created that grant the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manager' access to the IAM groups service."
  default     = false
}

variable "sm_tags" {
  type        = list(string)
  description = "The list of resource tags to associate with your Secrets Manager instance."
  default     = []
}

variable "allowed_network" {
  type        = string
  description = "The types of service endpoints to set on the Secrets Manager instance. Possible values are `private-only` or `public-and-private`. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-endpoints#service-endpoints)."
  default     = "public-and-private"
  validation {
    condition     = contains(["private-only", "public-and-private"], var.allowed_network)
    error_message = "The value is not valid. Possible values are `private-only` or `public-and-private`."
  }
}

variable "kms_encryption_enabled" {
  type        = bool
  description = "Set to `true` to control the encryption keys that are used to encrypt the data that you store in Secrets Manager. If set to `false`, the data that you store is encrypted at rest by using envelope encryption. For more details, go to  [About customer-managed keys](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-mng-data&interface=ui#about-encryption)."
  default     = false
}

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Whether to skip creating the IAM authorization policies that are required to enable the IAM credentials engine. If set to false, policies are created that grant the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manager' access to the IAM groups service."
  default     = false
}

variable "kms_key_crn" {
  type        = string
  description = "The root key CRN of a key management service like Key Protect or Hyper Protect Crypto Services that you want to use for encryption. Only used if `kms_encryption_enabled` is set to `true`."
  default     = null

  validation {
    condition     = var.kms_key_crn != null && var.kms_encryption_enabled == false ? false : true
    error_message = "When passing values for `var.kms_key_crn`, you must set 'kms_encryption_enabled' to `true`. Otherwise, set 'kms_encryption_enabled' to `false` to use default encryption."
  }

  validation {
    condition     = var.existing_sm_instance_crn == null ? var.kms_encryption_enabled == true && var.kms_key_crn == null ? false : true : true
    error_message = "When setting `var.kms_encryption_enabled` to `true`, a value must be passed for `var.kms_key_crn`."
  }
}

variable "is_hpcs_key" {
  type        = bool
  description = "Set to `true` if the key provided through the `kms_key_crn` is a Hyper Protect Crypto Services key."
  default     = false
}

variable "existing_sm_instance_crn" {
  type        = string
  description = "An existing Secrets Manager instance CRN. If not provided, a new instance is created."
  default     = null

  validation {
    condition     = var.existing_sm_instance_crn == null && var.region == null ? false : true
    error_message = "When `existing_sm_instance_crn` is set to `null`, a value must be passed for `var.region`."
  }
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
  description = "The context-based restrictions rule to create. Only one rule is allowed."
  default     = []
  # Validation happens in the rule module
  validation {
    condition     = length(var.cbr_rules) <= 1
    error_message = "Only one CBR rule is allowed."
  }
}

##############################################################################
# Event Notification
##############################################################################

variable "skip_en_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip creating an IAM authorization policy that permits all Secrets Manager instances (scoped to the resource group) an 'Event Source Manager' role to the given Event Notifications instance passed in the `existing_en_instance_crn` input variable. No policy is created if `enable_event_notification` is set to `false`."
  default     = false
}

variable "enable_event_notification" {
  type        = bool
  default     = false
  description = "Set to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When set to `true`, a value must be passed for `existing_en_instance_crn` and `existing_sm_instance_crn` must be set to `null`."

  validation {
    condition     = var.enable_event_notification == true && var.existing_en_instance_crn == null ? false : true
    error_message = "When setting `var.enable_event_notification` to `true`, a value must be passed for `var.existing_en_instance_crn`."
  }
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
    error_message = "The specified `endpoint_type` is not valid. Possible values are `public` or `private`."
  }

  validation {
    condition     = var.endpoint_type == "public" && var.allowed_network == "private-only" ? false : true
    error_message = "It is not allowed to have conflicting `var.endpoint_type` and `var.allowed_network` values."
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
    create_access_group      = optional(bool, false)
    access_group_name        = optional(string)
    access_group_roles       = optional(list(string))
    access_group_tags        = optional(list(string))
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
      custom_credentials_configurations           = optional(string)
      custom_credentials_parameters               = optional(bool, false)
      job_parameters = optional(object({
        integer_values = optional(map(number))
        string_values  = optional(map(string))
        boolean_values = optional(map(bool))
      }), {})
    })))
  }))
  description = "Secret Manager secrets configurations."
  default     = []
}
