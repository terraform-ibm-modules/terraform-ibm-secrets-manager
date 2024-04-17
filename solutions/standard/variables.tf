########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API Key to use for IBM Cloud."
  sensitive   = true
}

variable "existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision Secrets Manager resources to. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'"
}

variable "region" {
  type        = string
  description = "The region in which to provision Secrets Manager resources."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "(Optional) Prefix to append to all resources created by this solution."
  default     = null
}

########################################################################################################################
# Secrets Manager
########################################################################################################################

variable "secrets_manager_instance_name" {
  type        = string
  description = "The name to give the Secrets Manager instance that will be provisioned by this solution. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'"
  default     = "base-security-services-sm"
}

variable "service_plan" {
  type        = string
  description = "The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: 'standard' and 'trial'. Only used if `provision_sm_instance` is set to true."
  default     = "standard"
  validation {
    condition     = contains(["standard", "trial"], var.service_plan)
    error_message = "Allowed values for sm_service_plan are \"standard\" and \"trial\"."
  }
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

variable "secret_manager_tags" {
  type        = list(any)
  description = "The list of resource tags that you want to associate with your Secrets Manager instance."
  default     = []
}

variable "iam_engine_enabled" {
  type        = bool
  description = "Set this to true to to configure an IBM Secrets Manager IAM credentials engine. If set to false, no iam engine will be configured for your secrets manager instance. For more details, see https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-configure-iam-engine."
  default     = false
}

variable "iam_engine_name" {
  type        = string
  description = "The name of the IAM Engine used to configure an IBM Secrets Manager IAM credentials engine. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'"
  default     = "base-sm-iam-engine"
}

########################################################################################################################
# Key Protect
########################################################################################################################

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the existing_kms_instance_guid variable."
  default     = false
}

variable "existing_sm_kms_key_crn" {
  type        = string
  description = "The CRN of an existing KMS key to use for Secrets Manager. If not supplied, a new key ring and key will be created."
  default     = null
}

variable "kms_region" {
  type        = string
  default     = "us-south"
  description = "The region in which KMS instance exists."
}

variable "existing_kms_guid" {
  type        = string
  default     = null
  description = "The GUID of of the KMS instance used for the Secrets Manager root Key. Only required if not supplying an existing KMS root key and if 'skip_cos_kms_auth_policy' is true."
}

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to be used for communicating with the KMS instance. Allowed values are: 'public' or 'private' (default)"
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "The kms_endpoint_type value must be 'public' or 'private'."
  }
}

variable "kms_key_ring_name" {
  type        = string
  default     = "sm-cos-key-ring"
  description = "The name to give the Key Ring which will be created for the Secrets Manager COS bucket Key. Not used if supplying an existing Key. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'"
}

variable "kms_key_name" {
  type        = string
  default     = "sm-cos-key"
  description = "The name to give the Key which will be created for the Secrets Manager COS bucket. Not used if supplying an existing Key. If prefix input variable is passed then it will get prefixed infront of the value in the format of '<prefix>-value'"
}

########################################################################################################################
# Event Notifications
########################################################################################################################

variable "existing_en_instance_crn" {
  type        = string
  description = "The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance."
  default     = null
}

variable "skip_en_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances (scoped to the resource group) an 'Event Source Manager' role to the given Event Notifications instance passed in the `existing_en_instance_crn` input variable."
  default     = false
}
