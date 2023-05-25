
#Create a virtual network with multiple subnets
resource "azurerm_virtual_network" "tf-vnet" {
  name                = "vnet-${var.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = ["10.42.0.0/16"]

  tags = var.tags
}

resource "azurerm_subnet" "tf-ask-subnet" {
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  name                 = "aks-${var.prefix}"
  address_prefixes     = ["10.42.1.0/24"]
}
