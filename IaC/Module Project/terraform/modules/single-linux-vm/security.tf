locals {
  nsg_inbound_rules = { for idx, security_rule in var.nsg_inbound_rules : security_rule.name => {
    idx : idx,
    security_rule : security_rule,
    }
  }
}

#---------------------------------------
# Network Security group
#---------------------------------------
resource "azurerm_network_security_group" "nsg" {
 
  name                = "nsg-${local.vm_name}-${var.subsequent_vm_number}"
  #name                = "nsg-${local.vm_name}-${count.index + 1}"
  #name                = "${local.nsg}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    tags     = var.project_tags

  depends_on = [azurerm_resource_group.rg]
}

#---------------------------------------
# Network Security group Association
#---------------------------------------
resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  
  subnet_id                 = azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  
depends_on = [azurerm_subnet.snet]
}

#---------------------------------------
# Network Security group Rules
#---------------------------------------
resource "azurerm_network_security_rule" "nsg_rule" {
  for_each                    = { for k, v in local.nsg_inbound_rules : k => v if k != null }
  name                        = each.key
  priority                    = 100 * (each.value.idx + 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.security_rule.destination_port_range
  source_address_prefix       = each.value.security_rule.source_address_prefix
  destination_address_prefix  = element(concat(azurerm_subnet.snet.address_prefixes, [""]), 0)
  description                 = "Inbound_Port_${each.value.security_rule.destination_port_range}"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  depends_on                  = [azurerm_network_security_group.nsg]
}