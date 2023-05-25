# Generate random password
resource "random_password" "win-vm-password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  special          = true
  override_special = "!@#$%&"

}

##########RGs######
#original RG
resource "azurerm_resource_group" "tf-rg-we" {
  name     = "rg-${var.prefix-we}"
  location = var.location-we
  tags     = var.tags
}
#replica RG
resource "azurerm_resource_group" "tf-rg-ne" {
  name     = "rg-${var.prefix-ne}"
  location = var.location-ne
  tags     = var.tags
}
#infrastructure RG
resource "azurerm_resource_group" "tf-rg-ne-asr" {
  name     = "rg-${var.prefix-ne-asr}"
  location = var.location-ne
  tags     = var.tags
}






