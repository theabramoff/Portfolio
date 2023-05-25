output "rg-output" {
  value = azurerm_resource_group.rg.name
}

output "vnet-output" {
  value = azurerm_virtual_network.vnet.name
}

output "snet-output" {
  value = azurerm_subnet.snet.name
}
/*
output "ask-output" {
  value = azurerm_kubernetes_cluster.kubernetes.name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.kubernetes.kube_config_raw

  sensitive = true
}
*/
