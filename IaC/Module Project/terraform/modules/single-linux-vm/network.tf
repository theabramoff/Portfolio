#---------------------------------------
# Virtual network
#---------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.vnet}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_segment]

  tags     = var.project_tags

depends_on = [azurerm_resource_group.rg]
}

#---------------------------------------
# Subnet
#---------------------------------------
resource "azurerm_subnet" "snet" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = "${local.snet}"
  address_prefixes     = [var.subnet]
}

#---------------------------------------
# Virtual machine Static IP
#---------------------------------------
resource "azurerm_public_ip" "pip" {
  #name                = "pip-${local.vm_name}-${lookup(var.instance_number, count.index + 1)}"
  name                = "pip-${local.vm_name}-${var.subsequent_vm_number}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  tags     = var.project_tags

depends_on = [azurerm_resource_group.rg]
}