# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.80.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "tf-rg" {
    name     = "rg-az01-01-abramov-terraform-test"
    location = "westeurope"

    tags = {
        Description       = "new RG for terraform"
        OwnedBy           = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}