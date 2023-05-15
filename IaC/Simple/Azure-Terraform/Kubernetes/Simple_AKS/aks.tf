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

# Create a resource group
resource "azurerm_resource_group" "tf-rg" {
    name     = "rg-az01-abramov-aks-terraform"
    location = "westeurope"

    tags = {
        Description = "new RG for terraform"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"

    }
}

resource "azurerm_kubernetes_cluster" "tf-aks" {
  name                = "aks-abramov-aks-terraform"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  dns_prefix          = "abramovakstest"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
        Description = "new RG for terraform"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
        Environment = "test"
    }
  }


output "client_certificate" {
  value = azurerm_kubernetes_cluster.tf-aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.tf-aks.kube_config_raw

  sensitive = true
}