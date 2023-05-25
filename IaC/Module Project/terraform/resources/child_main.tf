locals {
    subscription_code = "01"
    environment       = "sbx"
}

module "storage-we" {
  source                = "./storage/we"
  location              = "westeurope"
  location_code         = "we"
  environment           = local.environment 
  subscription_code     = local.subscription_code
}

module "kubernetes-we" {
  source                = "./kubernetes/we"
  location              = "westeurope"
  location_code         = "we"
  subscription_code     = local.subscription_code
}

module "single-linux-vm-we" {
  source                = "./vm/we"
  location              = "westeurope"
  location_code         = "we"
  subscription_code     = local.subscription_code
}
