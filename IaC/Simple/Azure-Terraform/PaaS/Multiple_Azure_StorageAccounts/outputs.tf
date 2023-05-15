output "resource_group_name" {
  value = azurerm_resource_group.tf-rg.name
}

output "storage" {
  value = [azurerm_storage_account.tf-storage[*].name]
}





