resource "azurerm_logic_app_workflow" "tf-logic" {
  name                = var.logic
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  tags                = var.tags
}