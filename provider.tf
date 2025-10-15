terraform {
  required_providers {
    azurerm = {
      version = "3.90.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}
