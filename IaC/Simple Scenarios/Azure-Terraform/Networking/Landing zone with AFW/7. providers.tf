#TF provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.82.0"
    }
  }
  /*
  #define backend for remote state on S3
  backend "azurerm" {
  resource_group_name  = "< ... >"
  storage_account_name = "< ... >"
  container_name       = "terraformstate"
  key                  = "tf-state.tfstate"
  }
*/
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
   features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
   }
}
