########recovery services vault###########
resource "azurerm_recovery_services_vault" "tf-vault" {
  name                     = "rsv-${var.prefix-resource-ne}"
  resource_group_name      = azurerm_resource_group.tf-rg-ne-asr.name
  location                 = azurerm_resource_group.tf-rg-ne-asr.location
  sku                      = "Standard"
  storage_mode_type        = "LocallyRedundant" 

  soft_delete_enabled = true

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne
  ]
}

#####policies#####
resource "azurerm_site_recovery_replication_policy" "tf-policy-1" {
  name                                                 = "policy-1"
  resource_group_name      = azurerm_resource_group.tf-rg-ne-asr.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.tf-vault.name
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_recovery_services_vault.tf-vault
  ]
}