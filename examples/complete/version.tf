terraform {
  required_version = ">= v1.0.0, <1.6.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.56.1"
    }
  }
}
