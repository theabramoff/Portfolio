
#---------------------------------------
# Virtual network
#---------------------------------------
resource "azurerm_virtual_network" "vnet-hub" {
  name                = local.vnet_hub
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_hub_segment]

  tags = var.project_tags

  depends_on = [azurerm_resource_group.rg]
}

#---------------------------------------
# Subnet Azure Bastion
#---------------------------------------
resource "azurerm_subnet" "snet-bastion" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  name                 = "AzureBastionSubnet"
  address_prefixes     = [var.subnet_bastion]

  depends_on = [azurerm_virtual_network.vnet-hub]
}

#---------------------------------------
# Subnet Azure Firewall 
#---------------------------------------
resource "azurerm_subnet" "snet-firewall" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  name                 = "AzureFirewallSubnet"
  address_prefixes     = [var.subnet_firewall]

  depends_on = [azurerm_virtual_network.vnet-hub]
}

#---------------------------------------
# Subnet Azure Application Gateway 
#---------------------------------------
resource "azurerm_subnet" "snet-appgtw" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  name                 = "AzureApplicationGatewaySubnet"
  address_prefixes     = [var.subnet_appgtw]

  depends_on = [azurerm_virtual_network.vnet-hub]
}

#---------------------------------------
# Azure Private DNS Zone
#---------------------------------------
resource "azurerm_private_dns_zone" "dns-zone" {
  name                = var.dns_zone
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.project_tags
  
  depends_on = [azurerm_virtual_network.vnet-hub]
}

#---------------------------------------
# Azure Private DNS Zone Link
#---------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "dns-link" {
  name                  = "link-to-${local.vnet_hub}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet-hub.id
  registration_enabled  = "true"

  tags = var.project_tags

  depends_on = [azurerm_virtual_network.vnet-hub]
}

#---------------------------------------
# Route Table firewall subnet 
#---------------------------------------
resource "azurerm_route_table" "rt-hub" {
  name                          = local.rt_hub
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  disable_bgp_route_propagation = true

  tags = var.project_tags
  
  depends_on = [azurerm_virtual_network.vnet-hub]
}

resource "azurerm_route" "route-hub-default-01" {
  resource_group_name    = azurerm_resource_group.rg.name
  name                   = "default"
  route_table_name       = azurerm_route_table.rt-hub.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "Internet"
  #next_hop_in_ip_address = "0.0.0.0/0"

  depends_on = [azurerm_subnet.snet-firewall]
}

resource "azurerm_subnet_route_table_association" "rt-hub-association" {
  subnet_id      = azurerm_subnet.snet-firewall.id
  route_table_id = azurerm_route_table.rt-hub.id

  depends_on = [azurerm_route_table.rt-hub]
}