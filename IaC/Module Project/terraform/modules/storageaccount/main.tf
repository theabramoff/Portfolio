locals {
sa_name = format("sa%s%s%s", var.location_code,var.subscription_code, var.environment)
rg_name = var.create_resource_group  == true ?  format("rg-az%s%s-", var.location_code, var.subscription_code) : var.resource_group_name 


}

resource "azurerm_resource_group" "resourcegroup" {
  count    = var.instance_count

  name     = "${local.rg_name}${var.rg_suffix}-${count.index + 1}"
  location = var.location
  #tags     = var.project_tags
}

resource "azurerm_storage_account" "storageaccount" {
  count = var.instance_count

  name                      = "${local.sa_name}${var.sa_suffix}${count.index + 1}"
  resource_group_name       = azurerm_resource_group.resourcegroup[count.index].name
  location                  = azurerm_resource_group.resourcegroup[count.index].location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = var.redundancy  # "LRS"

  #tags = {
    #environment = var.environment
  #}
}
