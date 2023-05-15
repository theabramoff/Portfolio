
resource "azurerm_app_service_plan" "tf-asp-1" {
  name                = var.asp1
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  kind                = var.kind
  reserved            = true

  sku {
    tier = var.tier
    size = var.size
  }
  depends_on = [azurerm_resource_group.tf-rg]
}

resource "azurerm_app_service_plan" "tf-asp-2" {
  name                = var.asp2
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  kind                = var.kind
  reserved            = true

  sku {
    tier = var.tier
    size = var.size
  }
depends_on = [azurerm_resource_group.tf-rg]
}
