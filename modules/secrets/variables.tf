##############################################################################
# Secret Manager Variables
##############################################################################

variable "existing_sm_instance_region" {
  type        = string
  description = "Region which the Secret Manager is deployed."
}

variable "existing_sm_instance_guid" {
  type        = string
  description = "Instance ID of Secrets Manager instance in which the Secret will be added."
}

variable "endpoint_type" {
  type        = string
  description = "The service endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`"
  default     = "public"
}

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
  validation {
    error_message = "The name of the secret group cannot be null or empty string."
    condition = length([
      for secret in var.secrets :
      true if(secret.secret_group_name == "" || secret.secret_group_name == null)
    ]) == 0
  }
  validation {
    error_message = "The `default` secret group already exist, set `existing_secret_group` flag to true."
    condition = length([
      for secret in var.secrets :
      true if(secret.secret_group_name == "default" && secret.existing_secret_group == false)
    ]) == 0
  }
}
