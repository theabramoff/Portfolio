resource "azurerm_resource_group" "tf-rg" {
  name     = "rg-az01-synapse-terrafrom-test"
  location = "West Europe"
}

resource "azurerm_storage_account" "tf-sa" {
  name                     = "sa0101dldwh"
  resource_group_name      = azurerm_resource_group.tf-rg.name
  location                 = azurerm_resource_group.tf-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "tf-fs" {
  name               = "dwh"
  storage_account_id = azurerm_storage_account.tf-sa.id
}
# replace administrator_password with < ... > with password
resource "azurerm_synapse_workspace" "tf-syn" {
  name                                 = "sqlsa-az01-synapse-terrafrom-test"
  resource_group_name                  = azurerm_resource_group.tf-rg.name
  location                             = azurerm_resource_group.tf-rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.tf-fs.id
  sql_administrator_login              = "sqladmin"
  sql_administrator_login_password     = "< ... >"

identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_synapse_sql_pool" "tf-spool" {
  name                 = "sqldwh-az01-synapse-terrafrom-test"
  synapse_workspace_id = azurerm_synapse_workspace.tf-syn.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}

  
  