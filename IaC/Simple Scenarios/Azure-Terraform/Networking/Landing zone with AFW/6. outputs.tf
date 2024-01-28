output "rg-output" {
  value = azurerm_resource_group.rg.name
}

output "vnet-hub-output" {
  value = azurerm_virtual_network.vnet-hub.name
}

output "vnet-hub-cidr-output" {
  value = azurerm_virtual_network.vnet-hub.address_space
}

output "dns-zone-output" {
  value = azurerm_private_dns_zone.dns-zone.name
}

output "snet-bastion-cidr-output" {
  value = azurerm_subnet.snet-bastion.address_prefixes
}

output "snet-bastion-output" {
  value = azurerm_subnet.snet-bastion.name
}

output "snet-firewall-cidr-output" {
  value = azurerm_subnet.snet-firewall.address_prefixes
}

output "snet-firewall-output" {
  value = azurerm_subnet.snet-firewall.name
}

output "snet-appgtw-cidr-output" {
  value = azurerm_subnet.snet-appgtw.address_prefixes
}

output "snet-appgtw-output" {
  value = azurerm_subnet.snet-appgtw.name
}

output "rt-hub-output" {
  value = azurerm_route_table.rt-hub.name
}

output "nsg-bastion-output" {
  value = azurerm_network_security_group.nsg-bastion.name
}

output "pip-firewall-output" {
  value = azurerm_public_ip.pip-firewall-primary.name
}

output "pip-bastion-output" {
  value = azurerm_public_ip.pip-bastion.name
}

output "afw-policy-output" {
  value = azurerm_firewall_policy.afw-policy-01.name
}

output "afw-output" {
  value = azurerm_firewall.firewall.name
}

output "afw-sku-output" {
  value = azurerm_firewall.firewall.sku_tier
}

output "bastion-output" {
  value = azurerm_bastion_host.bastion.name
}

output "bastion-sku-output" {
  value = azurerm_bastion_host.bastion.sku
}