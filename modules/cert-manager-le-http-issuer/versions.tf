terraform {
  required_version = ">= 0.12.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 1.0.0"
    }
  }
}
