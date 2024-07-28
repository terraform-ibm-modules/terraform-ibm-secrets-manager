variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key this account authenticates to"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for sm instance"
  default     = "sm-com"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "en_region" {
  type        = string
  description = "Region where event notification will be created"
  default     = "au-syd"
}

variable "existing_sm_instance_crn" {
  type        = string
  description = "An existing Secrets Manager instance CRN. If not provided an new instance will be provisioned."
  default     = null
}

variable "service_credentials_secrets" {
  type = list(object({
    secret_group_name        = string
    secret_group_description = optional(string)
    existing_secret_group    = optional(bool, false)
    service_credentials = list(object({
      secret_name                             = string
      service_credentials_source_service_role = string
      secret_labels                           = optional(list(string))
      secret_auto_rotation                    = optional(bool)
      secret_auto_rotation_unit               = optional(string)
      secret_auto_rotation_interval           = optional(number)
      service_credentials_ttl                 = optional(string)
      service_credential_secret_description   = optional(string)
    }))
  }))
  default = [{
    secret_group_name     = "soaib-secret-group"
    existing_secret_group = true
    service_credentials = [{
      secret_name                             = "soaib-cred-1"
      service_credentials_source_service_role = "Editor"
      }, {
      secret_name                             = "soaib-cred-2"
      service_credentials_source_service_role = "Editor"
    }]
  }]
  description = "Service credentials secret configuration for COS"
}
