terraform {
  required_version = ">= 0.12.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 1.0.0"
    }
  }
}
