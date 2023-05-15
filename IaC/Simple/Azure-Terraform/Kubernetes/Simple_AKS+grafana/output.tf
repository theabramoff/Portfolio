output "RG-output" {
  value = azurerm_resource_group.tf-rg.name
}

/*output "RG-output2" {
  value = azurerm_resource_group.tf-rg2.name
}*/

output "RG-output2" {
  value = azurerm_kubernetes_cluster.tf-aks.node_resource_group
}

output "AKS-output" {
  value = azurerm_kubernetes_cluster.tf-aks.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.tf-aks.kube_config_raw
  sensitive = true
}