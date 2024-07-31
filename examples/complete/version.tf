terraform {
  required_version = ">= v1.0.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.65.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.2"
    }
  }
}
