output "rg-output" {
  value = "rg-${var.prefix}"
}

output "pip-output" {
  value = azurerm_public_ip.tf-pip.ip_address
}

output "pass-output" {
  value = random_password.linux-vm-password.result
  sensitive = true
}