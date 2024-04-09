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
  description = "The name of a new or an existing resource group in which to provision Secrets Manager resources to."
}

variable "region" {
  type        = string
  description = "The region in which to provision Secrets Manager resources."
  default     = "us-south"
}

########################################################################################################################
# Secrets Manager
########################################################################################################################

variable "secrets_manager_instance_name" {
  type        = string
  description = "The name to give the Secrets Manager instance that will be provisioned by this solution."
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

variable "service_endpoints" {
  # public-and-private until IBM Console connects to SM via private endpoints
  type        = string
  description = "The service endpoints to enable for all services deployed by this solution. Allowed values are `private` or `public-and-private`. If selecting `public-and-private`, communication to the instances will all be done over the public endpoints. Ensure to enable virtual routing and forwarding (VRF) in your account if using `private`, and that the terraform runtime has access to the the IBM Cloud private network."
  default     = "public-and-private"
  validation {
    condition     = contains(["private", "public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection. Allowed values are `private` or `public-and-private`."
  }
}

variable "secret_manager_tags" {
  type        = list(any)
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

variable "sm_key_ring_name" {
  type        = string
  default     = "sm-cos-key-ring"
  description = "The name to give the Key Ring which will be created for the Secrets Manager COS bucket Key. Not used if supplying an existing Key."
}

variable "sm_key_name" {
  type        = string
  default     = "sm-cos-key"
  description = "The name to give the Key which will be created for the Secrets Manager COS bucket. Not used if supplying an existing Key."
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
