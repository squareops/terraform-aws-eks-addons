terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.43.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.2"
    }
  }
}
