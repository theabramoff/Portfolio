#TF provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.91.0"
    }
  }
    #define backend for remote state on S3
    backend "azurerm" {
    resource_group_name  = "< ... >"
    storage_account_name = "< ... >"
    container_name       = "terraformstate"
    key                  = "tf-state.tfstate"
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}