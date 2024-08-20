terraform {
  required_version = ">= 0.12.26"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0" # Adjust version as per your requirement
    }
  }
}
