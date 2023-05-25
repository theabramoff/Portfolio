
output "rg-output" {
  value = azurerm_resource_group.rg.name
}

output "pip-output" {
  value = azurerm_public_ip.pip
}

output "vm-output" {
  value = azurerm_linux_virtual_machine.vm
}

output "pass-output" {
  value = random_password.password.result
  sensitive = true
}
