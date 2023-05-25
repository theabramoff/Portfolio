output "rg-output" {
  value = azurerm_resource_group.tf-rg.name
}

output "vnet-output" {
  value = azurerm_virtual_network.tf-vnet.name
}

output "snetask-output" {
  value = azurerm_subnet.tf-ask-subnet.name
}

output "snetafw-output" {
  value = azurerm_subnet.tf-afw-subnet.name
}

output "pipafw-output" {
  value = azurerm_public_ip.tf-afw-pip.name
}

output "afw-output" {
  value = azurerm_firewall.tf-afw.name
}

output "rt-output" {
  value = azurerm_route_table.tf-rt.name
}

output "ask-output" {
  value = azurerm_kubernetes_cluster.tf-aks.name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.tf-aks.kube_config_raw

  sensitive = true
}
