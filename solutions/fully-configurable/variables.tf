########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision resource in."
  default     = "Default"
  nullable    = false
}

variable "region" {
  type        = string
  description = "The region to provision resources to."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "The prefix to add to all resources created by this solution. To not use any prefix value, you can set this value to `null` or an empty string."

  validation {
    condition = (var.prefix == null ? true :
      alltrue([
        can(regex("^[a-z]{0,1}[-a-z0-9]{0,14}[a-z0-9]{0,1}$", var.prefix)),
        length(regexall("^.*--.*", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter, contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
  }
}

########################################################################################################################
# Secrets Manager
########################################################################################################################

variable "secrets_manager_instance_name" {
  type        = string
  description = "The name to give the Secrets Manager instance provisioned by this solution. If a prefix input variable is specified, it is added to the value in the `<prefix>-value` format. Applies only if `existing_secrets_manager_crn` is not provided."
  default     = "secrets-manager"
}

variable "existing_secrets_manager_crn" {
  type        = string
  description = "The CRN of an existing Secrets Manager instance. If not supplied, a new instance is created."
  default     = null
}

variable "service_plan" {
  type        = string
  description = "The pricing plan to use when provisioning a Secrets Manager instance. Possible values: `standard`, `trial`. You can create only one Trial instance of Secrets Manager per account. Before you can create a new Trial instance, you must delete the existing Trial instance and its reclamation. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-create-instance&interface=ui#upgrade-instance-standard)."
  validation {
    condition     = contains(["standard", "trial"], var.service_plan)
    error_message = "Only 'standard' and 'trial' are allowed values for 'service_plan'. Applies only if not providing a value for the 'existing_secrets_manager_crn' input."
  }
  validation {
    condition     = var.existing_secrets_manager_crn == null ? var.service_plan != null : true
    error_message = "A value for 'service_plan' is required if not providing a value for 'existing_secrets_manager_crn'"
  }
}

variable "skip_secrets_manager_iam_auth_policy" {
  type        = bool
  description = "Whether to skip the creation of the IAM authorization policies required to enable the IAM credentials engine (if you are using an existing Secrets Manager isntance, attempting to re-create can cause conflicts if the policies already exist). If set to false, policies will be created that grants the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manage' access to the IAM groups service."
  default     = false
}

variable "secrets_manager_resource_tags" {
  type        = list(any)
  description = "The list of resource tags you want to associate with your Secrets Manager instance. Applies only if `existing_secrets_manager_crn` is not provided."
  default     = []
}

variable "secrets_manager_endpoint_type" {
  type        = string
  description = "The type of endpoint (public or private) to connect to the Secrets Manager API. The Terraform provider uses this endpoint type to interact with the Secrets Manager API and configure Event Notifications."
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.secrets_manager_endpoint_type)
    error_message = "The specified service endpoint is not a valid selection!"
  }
}

variable "allowed_network" {
  type        = string
  description = "The types of service endpoints to set on the Secrets Manager instance. Possible values are `private-only` or `public-and-private`. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-endpoints#service-endpoints)."
  default     = "private-only"
  validation {
    condition     = contains(["private-only", "public-and-private"], var.allowed_network)
    error_message = "The specified allowed_network is not a valid selection!"
  }
}

variable "secret_groups" {
  type = list(object({
    secret_group_name        = string
    secret_group_description = optional(string)
    create_access_group      = optional(bool, true)
    access_group_name        = optional(string)
    access_group_roles       = optional(list(string), ["SecretsReader"])
    access_group_tags        = optional(list(string))
  }))
  description = "Secret Manager secret group and access group configurations. If a prefix input variable is specified, it is added to the `access_group_name` value in the `<prefix>-value` format. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/tree/main/solutions/fully-configurable/provisioning_secrets_groups.md)."
  nullable    = false
  default = [
    {
      secret_group_name        = "General"
      secret_group_description = "A general purpose secrets group with an associated access group which has a secrets reader role"
      create_access_group      = true
      access_group_name        = "general-secrets-group-access-group"
      access_group_roles       = ["SecretsReader"]
    }
  ]
  validation {
    error_message = "The name of the secret group cannot be null or empty string."
    condition = length([
      for group in var.secret_groups :
      true if(group.secret_group_name == "" || group.secret_group_name == null)
    ]) == 0
  }
  validation {
    error_message = "When creating an access group, a list of roles must be specified."
    condition = length([
      for group in var.secret_groups :
      true if(group.create_access_group && group.access_group_roles == null)
    ]) == 0
  }
}


########################################################################################################################
# Key Protect
########################################################################################################################

variable "skip_secrets_manager_kms_iam_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_crn` variable. If a value is specified for `ibmcloud_kms_api_key`, the policy is created in the KMS account."
  default     = false
}

variable "existing_secrets_manager_kms_key_crn" {
  type        = string
  description = "The CRN of a Key Protect or Hyper Protect Crypto Services key to use for Secrets Manager. If not specified, a key ring and key are created."
  default     = null
}

########################################################################################################################
# KMS properties required when creating an encryption key, rather than passing an existing key CRN.
########################################################################################################################

variable "kms_encryption_enabled" {
  type        = bool
  description = "Set to true to enable Secrets Manager Secrets Encryption using customer managed keys. When set to true, a value must be passed for either `existing_kms_instance_crn` or `existing_secrets_manager_kms_key_crn`. Cannot be set to true if passing a value for `existing_secrets_manager_crn`."
  default     = false

  validation {
    condition     = var.kms_encryption_enabled ? var.existing_secrets_manager_crn == null : true
    error_message = "'kms_encryption_enabled' should be false if passing a value for 'existing_secrets_manager_crn'."
  }

  validation {
    condition     = var.existing_secrets_manager_kms_key_crn != null ? var.kms_encryption_enabled : true
    error_message = "If passing a value for 'existing_secrets_manager_kms_key_crn', you should set 'kms_encryption_enabled' to true."
  }

  validation {
    condition     = var.existing_kms_instance_crn != null ? var.kms_encryption_enabled : true
    error_message = "If passing a value for 'existing_kms_instance_crn', you should set 'kms_encryption_enabled' to true."
  }

  validation {
    condition     = var.kms_encryption_enabled ? ((var.existing_kms_instance_crn != null || var.existing_secrets_manager_kms_key_crn != null) ? true : false) : true
    error_message = "Either 'existing_kms_instance_crn' or `existing_secrets_manager_kms_key_crn` is required if 'kms_encryption_enabled' is set to true."
  }
}

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the KMS instance (Hyper Protect Crypto Services or Key Protect). Required only if `existing_secrets_manager_crn` or `existing_secrets_manager_kms_key_crn` is not specified. If the KMS instance is in different account you must also provide a value for `ibmcloud_kms_api_key`."

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}(kms|hs-crypto):(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      var.existing_kms_instance_crn == null,
    ])
    error_message = "The provided KMS instance CRN in the input 'existing_kms_instance_crn' in not valid."
  }

  validation {
    condition     = var.existing_kms_instance_crn != null ? var.existing_secrets_manager_crn == null : true
    error_message = "A value should not be passed for 'existing_kms_instance_crn' when passing an existing secrets manager instance using the 'existing_secrets_manager_crn' input."
  }
}

variable "kms_endpoint_type" {
  type        = string
  description = "The endpoint for communicating with the Key Protect or Hyper Protect Crypto Services instance. Possible values: `public`, `private`. Applies only if `existing_secrets_manager_kms_key_crn` is not specified."
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "The kms_endpoint_type value must be 'public' or 'private'."
  }
}

variable "kms_key_ring_name" {
  type        = string
  default     = "secrets-manager-key-ring"
  description = "The name for the new key ring to store the key. Applies only if `existing_secrets_manager_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format. ."
}

variable "kms_key_name" {
  type        = string
  default     = "secrets-manager-key"
  description = "The name for the new root key. Applies only if `existing_secrets_manager_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format."
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud_api_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Secrets Manager instance. Leave this input empty if the same account owns both instances."
  sensitive   = true
  default     = null
}

########################################################################################################################
# Event Notifications
########################################################################################################################

variable "existing_event_notifications_instance_crn" {
  type        = string
  description = "The CRN of the Event Notifications service used to enable lifecycle notifications for your Secrets Manager instance."
  default     = null
}

variable "skip_secrets_manager_event_notifications_iam_auth_policy" {
  type        = bool
  description = "If set to true, this skips the creation of a service to service authorization from Secrets Manager to Event Notifications. If false, the service to service authorization is created."
  default     = false
}

variable "event_notifications_email_list" {
  type        = list(string)
  description = "The list of email address to target out when Secrets Manager triggers an event"
  default     = []
}

variable "event_notifications_from_email" {
  type        = string
  description = "The email address used to send any Secrets Manager event coming via Event Notifications"
  default     = "compliancealert@ibm.com"
}

variable "event_notifications_reply_to_email" {
  type        = string
  description = "The email address specified in the 'reply_to' section for any Secret Manager event coming via Event Notifications"
  default     = "no-reply@ibm.com"
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "secrets_manager_cbr_rules" {
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
  description = "(Optional, list) List of CBR rules to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/blob/main/solutions/fully-configurable/DA-cbr_rules.md)"
  default     = []
  # Validation happens in the rule module
}
