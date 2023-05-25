locals {
  rg_name = format("rg-az%s%s", local.location_code, local.subscription_code)
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${local.rg_name}-${var.rg_suffix}-${count.index + 1}"
  location = local.location
}
