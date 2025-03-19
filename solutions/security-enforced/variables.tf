########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision resource in."
}

variable "region" {
  type        = string
  description = "The region to provision resources to."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "The prefix to add to all resources created by this solution. To not use any prefix value, you can set this value to `null` or an empty string."
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
  description = "The pricing plan to use when provisioning a Secrets Manager instance. Possible values: `standard`, `trial`."
  default     = "standard"
  validation {
    condition     = contains(["standard", "trial"], var.service_plan)
    error_message = "Only \"standard\" and \"trial\" are allowed values for secrets_manager_service_plan.Applies only if not providing a value for the `existing_secrets_manager_crn` input."
  }
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to skip the creation of the IAM authorization policies required to enable the IAM credentials engine. If set to false, policies will be created that grants the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manage' access to the IAM groups service."
  default     = false
}

variable "secrets_manager_resource_tags" {
  type        = list(any)
  description = "The list of resource tags you want to associate with your Secrets Manager instance. Applies only if `existing_secrets_manager_crn` is not provided."
  default     = []
}

########################################################################################################################
# Key Protect
########################################################################################################################

variable "skip_kms_iam_authorization_policy" {
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

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the KMS instance (Hyper Protect Crypto Services or Key Protect). Required only if `existing_secrets_manager_crn` or `existing_secrets_manager_kms_key_crn` is not specified. If the KMS instance is in different account you must also provide a value for `ibmcloud_kms_api_key`."
}

variable "force_delete_kms_key" {
  type        = bool
  default     = false
  description = "If creating a new KMS key, toggle whether it should be force deleted or not on undeploy."
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

variable "enable_event_notifications" {
  type        = bool
  default     = false
  description = "Set this to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When setting this to true, a value must be passed for `existing_event_notification_instance_crn`"
}

variable "existing_event_notifications_instance_crn" {
  type        = string
  description = "The CRN of the Event Notifications service used to enable lifecycle notifications for your Secrets Manager instance."
  default     = null

  validation {
    condition     = (var.existing_event_notifications_instance_crn == null && var.enable_event_notifications) ? false : true
    error_message = "To enable event notifications, an existing event notifications CRN must be set."
  }
}

variable "skip_event_notifications_iam_authorization_policy" {
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
