# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
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
  #client_id       = ""
  #tenant_id       = ""
  #subscription_id = ""
  features {}
}

resource "azurerm_resource_group" "tf-rg1" {
  name     = "rg-az01-sql-01-dev"
  location = "westeurope"

  tags = {
    Description           = "[DEV] - rg 01"
    ITOwnerGroup          = "N/A"
    OwnedBy               = "Abramov, Andrey"
    OwnerBackupPerson     = "N/A"
    Region                = "USA"
    OperationalStatus     = "DEV"
    "Lifecycle End"       = "31DEC2023"
  }
}

resource "azurerm_resource_group" "tf-rg2" {
  name     = "rg-az01-srv-02-dev"
  location = "westeurope"

  tags = {
    Description           = "[DEV] - rg 02"
    ITOwnerGroup          = "N/A"
    OwnedBy               = "Abramov, Andrey"
    OwnerBackupPerson     = "N/A"
    Region                = "USA"
    OperationalStatus     = "DEV"
    "Lifecycle End"       = "31DEC2023"
  }
}

resource "azurerm_resource_group" "tf-rg3" {
  name     = "rg-az01-SRV-03-dev"
  location = "westeurope"

  tags = {
    Description           = "[DEV] - rg 03"
    ITOwnerGroup          = "N/A"
    OwnedBy               = "Abramov, Andrey"
    OwnerBackupPerson     = "N/A"
    Region                = "USA"
    OperationalStatus     = "DEV"
    "Lifecycle End"       = "31DEC2023"
  }
}

resource "azurerm_resource_group" "tf-rg4" {
  name     = "rg-az01-SRV-04-dev"
  location = "westeurope"

  tags = {
    Description           = "[DEV] - rg 04"
    ITOwnerGroup          = "N/A"
    OwnedBy               = "Abramov, Andrey"
    OwnerBackupPerson     = "N/A"
    Region                = "USA"
    OperationalStatus     = "DEV"
    "Lifecycle End"       = "31DEC2023"
  }
}

resource "azurerm_resource_group" "tf-rg5" {
  name     = "rg-az01-SRV-05-dev"
  location = "westeurope"

  tags = {
    Description           = "[DEV] - rg 05"
    ITOwnerGroup          = "N/A"
    OwnedBy               = "Abramov, Andrey"
    OwnerBackupPerson     = "N/A"
    Region                = "USA"
    OperationalStatus     = "DEV"
    "Lifecycle End"       = "31DEC2023"
  }
}

resource "azurerm_resource_group" "tf-rg6" {
  name     = "rg-az01-SRV-06-dev"
  location = "westeurope"

  tags = {
    Description           = "[DEV] - rg 06"
    ITOwnerGroup          = "N/A"
    OwnedBy               = "Abramov, Andrey"
    OwnerBackupPerson     = "N/A"
    Region                = "USA"
    OperationalStatus     = "DEV"
    "Lifecycle End"       = "31DEC2023"
  }
}

output "RG-output1" {
  value = azurerm_resource_group.tf-rg1
}
output "RG-output2" {
  value = azurerm_resource_group.tf-rg2
}
output "RG-output3" {
  value = azurerm_resource_group.tf-rg3
}
output "RG-output4" {
  value = azurerm_resource_group.tf-rg4
}
output "RG-output5" {
  value = azurerm_resource_group.tf-rg5
}
output "RG-output6" {
  value = azurerm_resource_group.tf-rg6
}