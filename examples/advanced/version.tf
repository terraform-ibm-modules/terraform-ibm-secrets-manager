terraform {
  required_version = ">= v1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.79.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
  }
}
