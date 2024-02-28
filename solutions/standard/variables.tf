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
  description = "The name of a new or an existing resource group in which to provision KMS resources to."
}

variable "region" {
  type        = string
  description = "The region in which to provision KMS resources. If using existing KMS, set this to the region in which it is provisioned in."
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

########################################################################################################################
# Key Protect
########################################################################################################################

variable "enable_kms_encryption" {
  type        = bool
  description = "Set this to true to control the encryption keys used to encrypt the data that you store in Secrets Manager. If set to false, the data that you store is encrypted at rest by using envelope encryption. For more details, see https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-mng-data&interface=ui#about-encryption."
  default     = false
}

variable "existing_kms_instance_guid" {
  type        = string
  description = "The CRN of an existing KMS instance to use."
  nullable    = true
  default     = null
}

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the existing_kms_instance_guid variable. In addition, no policy is created if kms_encryption_enabled is set to false."
  default     = true
}

variable "existing_kms_key_crn" {
  type        = string
  description = "The CRN of an existing KMS key to use for Secrets Manager. If not supplied, a new key ring and key will be created."
  default     = null
}

########################################################################################################################
# Event Notifications
########################################################################################################################

variable "enable_event_notification" {
  type        = bool
  description = "Set this to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When setting this to true, a value must be passed for `existing_en_instance_crn` variable."
  default     = false
}

variable "existing_en_instance_crn" {
  type        = string
  description = "The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance."
  default     = null
}

variable "skip_en_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances (scoped to the resource group) an 'Event Source Manager' role to the given Event Notifications instance passed in the `existing_en_instance_crn` input variable. In addition, no policy is created if `enable_event_notification` is set to false."
  default     = false
}
