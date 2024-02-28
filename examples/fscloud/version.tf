terraform {
  required_version = ">= 1.3.0, <1.6.0"
  required_providers {
    # Use latest version of provider in non-basic examples to verify latest version works with module
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.61.0, <2.0.0"
    }
  }
}
