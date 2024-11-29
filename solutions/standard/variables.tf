########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API Key to use for IBM Cloud."
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
variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or existing resource group to provision resources to. If a prefix input variable is specified, it's added to the value in the `<prefix>-value` format. Optional if `existing_secrets_manager_crn` is not specified."
  default     = null
}

variable "region" {
  type        = string
  description = "The region to provision resources to."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "The prefix to apply to all resources created by this solution."
  default     = null
  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", coalesce(var.prefix, "sm"))) && length(coalesce(var.prefix, "sm")) <= 16
  }
}

########################################################################################################################
# Secrets Manager
########################################################################################################################

variable "secrets_manager_instance_name" {
  type        = string
  description = "The name to give the Secrets Manager instance provisioned by this solution. If a prefix input variable is specified, it is added to the value in the `<prefix>-value` format."
  default     = "base-security-services-sm"
}

variable "existing_secrets_manager_crn" {
  type        = string
  description = "The CRN of an existing Secrets Manager instance. If not supplied, a new instance is created."
  default     = null
}

variable "existing_secrets_endpoint_type" {
  type        = string
  description = "The endpoint type to use if existing_secrets_manager_crn is specified. Possible values: public, private."
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.existing_secrets_endpoint_type)
    error_message = "Only \"public\" and \"private\" are allowed values for 'existing_secrets_endpoint_type'."
  }
}

variable "service_plan" {
  type        = string
  description = "The pricing plan to use when provisioning a Secrets Manager instance. Possible values: `standard`, `trial`. Applies only if `provision_sm_instance` is set to `true`."
  default     = "standard"
  validation {
    condition     = contains(["standard", "trial"], var.service_plan)
    error_message = "Only \"standard\" and \"trial\" are allowed values for sm_service_plan."
  }
}

variable "allowed_network" {
  type        = string
  description = "The types of service endpoints to set on the Secrets Manager instance. Possible values: `private-only`, `public-and-private`."
  default     = "private-only"
  validation {
    condition     = contains(["private-only", "public-and-private"], var.allowed_network)
    error_message = "The specified allowed_network is not a valid selection."
  }
}

variable "secret_manager_tags" {
  type        = list(any)
  description = "The list of resource tags you want to associate with your Secrets Manager instance."
  default     = []
}

variable "public_engine_enabled" {
  type        = bool
  description = "Set this to true to configure a Secrets Manager public certificate engine for an existing Secrets Manager instance. If set to false, no public certificate engine will be configured for your instance."
  default     = false
}

########################################################################################################################
# Public cert engine config
########################################################################################################################

variable "public_engine_name" {
  type        = string
  description = "The name of the IAM engine used to configure a Secrets Manager public certificate engine for an existing instance."
  default     = "public-engine-sm"
}

variable "cis_id" {
  type        = string
  description = "Cloud Internet Service ID."
  default     = null
}

variable "dns_provider_name" {
  type        = string
  description = "The name of the DNS provider for the public certificate secrets engine configuration."
  default     = "certificate-dns"
}

variable "ca_name" {
  type        = string
  description = "The name of the certificate authority for Secrets Manager."
  default     = "cert-auth"
}

variable "acme_letsencrypt_private_key" {
  type        = string
  description = "The private key generated by the ACME account creation tool."
  sensitive   = true
  default     = null
}

########################################################################################################################
# Private cert engine config
########################################################################################################################

variable "private_engine_enabled" {
  type        = bool
  description = "Set this to true to configure a Secrets Manager private certificate engine for an existing instance. If set to false, no private certificate engine will be configured for your instance."
  default     = false
}

variable "private_engine_name" {
  type        = string
  description = "The name of the IAM Engine used to configure a Secrets Manager private certificate engine for an existing instance."
  default     = "private-engine-sm"
}

variable "root_ca_name" {
  type        = string
  description = "The name of the root certificate authority associated with the private_cert secret engine."
  default     = "root-ca"
}

variable "root_ca_common_name" {
  type        = string
  description = "The fully qualified domain name or host domain name for the certificate that will be created."
  default     = "terraform-modules.ibm.com"
}

variable "root_ca_max_ttl" {
  type        = string
  description = "The maximum time-to-live value for the root certificate authority."
  default     = "87600h"
}

variable "intermediate_ca_name" {
  type        = string
  description = "A human-readable unique name to assign to the intermediate certificate authority configuration."
  default     = "intermediate-ca"
}

variable "certificate_template_name" {
  type        = string
  description = "The name of the certificate template."
  default     = "default-cert-template"
}

########################################################################################################################
# IAM engine config
########################################################################################################################

variable "iam_engine_enabled" {
  type        = bool
  description = "Set this to true to to configure a Secrets Manager IAM credentials engine. If set to false, no IAM engine will be configured for your instance."
  default     = false
}

variable "iam_engine_name" {
  type        = string
  description = "The name of the IAM engine used to configure a Secrets Manager IAM credentials engine. If the prefix input variable is passed it is attached before the value in the format of '<prefix>-value'."
  default     = "base-sm-iam-engine"
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

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to use for communicating with the Key Protect or Hyper Protect Crypto Services instance. Possible values: `public`, `private`. Applies only if `existing_secrets_manager_kms_key_crn` is not specified."
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "The kms_endpoint_type value must be 'public' or 'private'."
  }
}

variable "kms_key_ring_name" {
  type        = string
  default     = "sm-cos-key-ring"
  description = "The name for the new key ring to store the key. Applies only if `existing_secrets_manager_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format. ."
}

variable "kms_key_name" {
  type        = string
  default     = "sm-cos-key"
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

variable "enable_event_notification" {
  type        = bool
  default     = false
  description = "Set this to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When setting this to true, a value must be passed for `existing_en_instance_crn` and `existing_sm_instance_crn` must be null."
}

variable "existing_event_notification_instance_crn" {
  type        = string
  description = "The CRN of the Event Notifications service used to enable lifecycle notifications for your Secrets Manager instance."
  default     = null
}

variable "skip_event_notification_iam_authorization_policy" {
  type        = bool
  description = "If set to true, this skips the creation of a service to service authorization from Secrets Manager to Event Notifications. If false, the service to service authorization is created."
  default     = false
}

variable "sm_en_email_list" {
  type        = list(string)
  description = "The list of email address to target out when Secrets Manager triggers an event"
  default     = []
}

variable "sm_en_from_email" {
  type        = string
  description = "The email address in the used in the 'from' of any Secret Manager event coming from Event Notifications"
  default     = "compliancealert@ibm.com"
}

variable "sm_en_reply_to_email" {
  type        = string
  description = "The email address used in the 'reply_to' of any Secret Manager event coming from Event Notifications"
  default     = "no-reply@ibm.com"
}
