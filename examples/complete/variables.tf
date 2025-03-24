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
variable "sm_service_plan" {
  type        = string
  description = "The Secrets Manager service plan to provision"
  default     = "trial"
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "eu-de"
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
