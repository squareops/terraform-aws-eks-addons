terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
