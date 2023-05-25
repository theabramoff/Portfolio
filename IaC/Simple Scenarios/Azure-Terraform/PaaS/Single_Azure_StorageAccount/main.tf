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


resource "azurerm_resource_group" "tf-rg" {
  name     = var.resourcegroupname
  location = var.location

    tags = {
    OwnedBy = "Abramov, Andrey"
    Description = "test for tf"
  }
}

resource "azurerm_storage_account" "tf-sa" {
  name                     = var.storage
  resource_group_name      = "${azurerm_resource_group.tf-rg.name}"
  location                 = "${azurerm_resource_group.tf-rg.location}"
  account_tier             = "Standard"
  account_replication_type = var.redundancy

  tags = {
    OwnedBy = "Abramov, Andrey"
    Description = "test for tf"
  }
}
