
# resource group creation
resource "azurerm_resource_group" "tf-rg" {
  name     = var.rg
  location = var.location
  tags     = var.tags
}

# deployment of 2 new storage accounts in a row
resource "azurerm_storage_account" "tf-storage" {

  count = 2

  name                     = "${var.storage}${count.index + 1}"
  resource_group_name      = azurerm_resource_group.tf-rg.name
  location                 = azurerm_resource_group.tf-rg.location
  account_tier             = "Standard"
  account_replication_type = var.redundancy
  tags                     = var.tags
}
