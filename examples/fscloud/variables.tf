variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API token this account authenticates to"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for sm instance"
  default     = "secrets-manager-test"
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "us-east"
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
