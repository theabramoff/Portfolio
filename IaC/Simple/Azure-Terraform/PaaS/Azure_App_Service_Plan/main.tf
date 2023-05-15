#
#
#
#resource group for the environment
resource "azurerm_resource_group" "tf-rg" {
  name     = var.rg
  location = var.location

  tags = var.tags

}



