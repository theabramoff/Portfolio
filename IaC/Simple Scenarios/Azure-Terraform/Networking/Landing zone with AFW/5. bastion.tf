
#---------------------------------------
# Azure Bastion Public IP
#---------------------------------------
resource "azurerm_public_ip" "pip-bastion" {
  name                = "pip-${local.bastion}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.project_tags
}

#---------------------------------------
# Azure Bastion
#---------------------------------------
resource "azurerm_bastion_host" "bastion" {
  name                = "${local.bastion}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.bastion_sku

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.snet-bastion.id
    public_ip_address_id = azurerm_public_ip.pip-bastion.id
  }

  tags = var.project_tags

  depends_on = [azurerm_network_security_group.nsg-bastion]
}
