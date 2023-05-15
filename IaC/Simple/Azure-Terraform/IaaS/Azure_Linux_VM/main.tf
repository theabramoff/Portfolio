
resource "azurerm_resource_group" "tf-rg" {
  name     = "rg-${var.prefix}"
  location = var.location
  tags     = var.tags
}

# Generate random password
resource "random_password" "linux-vm-password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  number           = true
  special          = true
  override_special = "!@#$%&"

}