#---------------------------------------
# Route table
#---------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.vnet}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_segment]
  dns_servers         = var.dns

  tags     = var.project_tags
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
# Route table
#---------------------------------------
resource "azurerm_route_table" "rt" {
name                          = local.rt
location                      = azurerm_resource_group.rg.location
resource_group_name           = azurerm_resource_group.rg.name
dynamic "route" {
    for_each                  = var.routes  
    content {
      name                    = route.value.name
      address_prefix          = route.value.address_prefix
      next_hop_type           = route.value.next_hop_type
      next_hop_in_ip_address  = route.value.next_hop_in_ip_address #lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  tags                          = var.project_tags
}

#---------------------------------------
# Route table link to snet
#---------------------------------------
resource "azurerm_subnet_route_table_association" "rt-link" {
  subnet_id      = azurerm_subnet.snet.id
  route_table_id = azurerm_route_table.rt.id
}