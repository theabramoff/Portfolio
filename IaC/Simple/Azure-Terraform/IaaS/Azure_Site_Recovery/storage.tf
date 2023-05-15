###########storage######
#storage for replication in WE
resource "azurerm_storage_account" "tf-sa-we" {
  name                     = var.storage
  resource_group_name      = azurerm_resource_group.tf-rg-ne-asr.name
  location                 = var.location-we
  account_tier             = var.tier
  account_replication_type = var.redundancy

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne
  ]
}