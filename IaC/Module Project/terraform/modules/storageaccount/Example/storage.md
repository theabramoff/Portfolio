
locals {

}

module "storageaccount-01" {
  source = "../../../../modules/storageaccount"
  
  subscription_code       = var.subscription_code
  resource_group_name     = var.resource_group_name
  resource_group_location = var.location
  rg_suffix               = "terraform-test"
  sa_suffix               = "trfm"
  environment             = var.environment
  location                = var.location
  location_code           = var.location_code
  redundancy              = "LRS"
  instance_count          = 1
}
