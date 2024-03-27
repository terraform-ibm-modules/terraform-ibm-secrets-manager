########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API Key to use for IBM Cloud."
  sensitive   = true
}

variable "use_existing_resource_group" {
  type        = bool
  description = "A flag to create a resource group(true) or to use a preexisting resource group (false) specified in the variable resource_group_name"
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision the Secrets Manager resources to."
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
  description = "The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: 'standard' and 'trial'."
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

variable "create_kms_iam_authorization_policy" {
  type        = bool
  description = "A flag to create an IAM authorization that grants Secrets Manager access to a Key Protect resource(true) or not(false). Set to false if a preexisting authorization can be used."
  default     = true
}

variable "existing_sm_kms_key_crn" {
  type        = string
  description = "The CRN of an existing KMS key to use for Secrets Manager. If not supplied, a new key ring and new key will be created."
  default     = null
}

variable "kms_region" {
  type        = string
  default     = "us-south"
  description = "The region in which KMS instance exists."
}

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the KMS instance used for the Secrets Manager root Key. Only required if not supplying an existing KMS root key and if 'create_kms_iam_authorization_policy' is true."
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

variable "sm_data_encryption_key_ring" {
  type        = string
  default     = "sm-data-encryption-key-ring"
  description = "The name to give the Key Ring which will be created for the Secrets Manager COS bucket Key. Not used if supplying an existing Key."
}

variable "sm_data_encryption_key" {
  type        = string
  default     = "sm-data-encryption-key"
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

variable "create_en_iam_authorization_policy" {
  type        = bool
  description = "A flag to create an IAM authorization that grants Secrets Manager access to a Event Notification resource(true) or not(false). Set to false if a preexisting authorization can be used."
  default     = true
}
