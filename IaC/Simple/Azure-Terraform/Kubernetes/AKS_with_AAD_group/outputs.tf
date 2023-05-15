output "rg-output" {
  value = azurerm_resource_group.tf-rg.name
}

output "vnet-output" {
  value = azurerm_virtual_network.tf-vnet.name
}

output "snetask-output" {
  value = azurerm_subnet.tf-ask-subnet.name
}

output "ask-output" {
  value = azurerm_kubernetes_cluster.tf-aks.name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.tf-aks.kube_config_raw

  sensitive = true
}
