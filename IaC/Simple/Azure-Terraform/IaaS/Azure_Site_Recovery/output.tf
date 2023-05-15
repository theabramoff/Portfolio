output "rg-output-we" {
  value = "rg-${var.prefix-we}"
}

output "rg-output-ne" {
  value = "rg-${var.prefix-ne}"
}

output "rg-output-infrastructure" {
  value = "rg-${var.prefix-ne-asr}"
}

output "pip-output-we" {
  value = azurerm_public_ip.tf-pip-we.ip_address
}

output "pip-output-ne" {
  value = azurerm_public_ip.tf-pip-ne.ip_address
}

output "pass-output" {
  value = random_password.win-vm-password.result
  sensitive = true
}

output "vm-name" {
  value = azurerm_virtual_machine.tf-vm.name
}