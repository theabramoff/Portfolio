
#---------------------------------------
# TF provider
#---------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

#---------------------------------------
# Deployment
#---------------------------------------

resource "azurerm_resource_group" "tf-rg" {
  name     = "rg-az01-mysql-01"
  location = "westeurope"

  tags = {
    OwnedBy               = "Abramov, Andrey"
    OwnerBackupPerson     = "N/A"
    ITOwnerGroup          = "N/A"
    Description           = "DEMO"
    Region                = "USA"
    OperationalStatus     = "DEV"
    LifecycleEnd        = "31DEC2023"
  }
}

# replace administrator_password with < ... > with password
resource "azurerm_mysql_flexible_server" "tf-mysql" {
  name                   = "mysqldb-az01-mysql-01"
  resource_group_name    = azurerm_resource_group.tf-rg.name
  location               = azurerm_resource_group.tf-rg.location
  administrator_login    = "psqladmin"
  administrator_password = "< ... >"
  backup_retention_days  = 7
  geo_redundant_backup_enabled  = false
  #delegated_subnet_id    = azurerm_subnet.example.id
  #private_dns_zone_id    = azurerm_private_dns_zone.example.id
  sku_name = "GP_Standard_D2ds_v4"

  #depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
}