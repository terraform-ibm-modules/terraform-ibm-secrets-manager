variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
}

variable "region" {
  type        = string
  description = "Region"
}

variable "provision_secrets_manager" {
  type        = bool
  description = "Set it to true to provision a secrets manager"
  default     = false
}
