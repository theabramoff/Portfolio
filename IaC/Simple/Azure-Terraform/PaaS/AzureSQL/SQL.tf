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

resource "azurerm_resource_group" "tf-rg-sql-srv" {
    name     = "rg-az01-abramov-terraform-sql-server-test"
    location = "westeurope"

    tags = {
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
    }
}
# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "tf-rg-sql-db" {
    name     = "rg-az01-abramov-terraform-sql-dbtest"
    location = "westeurope"

    tags = {
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
    }
}
# replace administrator_password with < ... > with password
resource "azurerm_sql_server" "tf-sql-srv" {
  name                         = "sql-az01-tf"
  resource_group_name          = azurerm_resource_group.tf-rg-sql-srv.name
  location                     = "westeurope"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "< ... >"

}

resource "azurerm_storage_account" "tf-sa" {
  name                     = "sa0101sqltf"
  resource_group_name      = azurerm_resource_group.tf-rg-sql-srv.name
  location                 = azurerm_resource_group.tf-rg-sql-srv.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "tf-sql-db" {
  name                = "myexamplesqldatabase"
  resource_group_name = azurerm_resource_group.tf-rg-sql-srv.name
  location            = "westeurope"
  server_name         = azurerm_sql_server.tf-sql-srv.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.tf-sa.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.tf-sa.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

}