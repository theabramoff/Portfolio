  locals {
  rg_name       = var.create_resource_group == true ? format("rg-az%sx%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment) : var.resource_group_name
  vnet_hub      = format("vnet-az%sx%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
  rt_hub        = format("rt-az%sx%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
  nsg_bastion   = format("nsg-az%sx%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
  policy        = format("afwp-az%sx%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
  firewall      = format("afw-az%sx%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
  bastion       = format("bastion-az%sx%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
  loganalytics  = format("law-az%sx%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
}

#---------------------------------------
# Resource group
#---------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  
  tags     = var.project_tags
}


#---------------------------------------
# Azure Log Analytics workspace
#---------------------------------------
resource "azurerm_log_analytics_workspace" "example" {
  name                = "${local.loganalytics}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.project_tags
}