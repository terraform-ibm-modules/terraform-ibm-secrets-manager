variable "prefix" {
  type        = string
  description = "Prefix to append to all resources"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
}
