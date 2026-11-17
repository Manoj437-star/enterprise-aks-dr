terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Remote backend configuration (optional, can be toggled by passing -backend-config)
  # backend "azurerm" {
  #   resource_group_name  = "rg-mlops-tfstate-poc"
  #   storage_account_name = "stmlopstfdfb9yd"
  #   container_name       = "tfstate"
  #   key                  = "dr-primary.terraform.tfstate"
  # }
}
