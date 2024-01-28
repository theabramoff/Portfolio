#---------------------------------------
# Primary Azure Firewall Public IP
#---------------------------------------
resource "azurerm_public_ip" "pip-firewall-primary" {
  name                = "pip-${local.firewall}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.project_tags
}

#---------------------------------------
# Primary Azure Firewall Policy
#---------------------------------------
resource "azurerm_firewall_policy" "afw-policy-01" {
  name                     = local.policy
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = var.firewall_sku_tier
  threat_intelligence_mode = "Alert"
  
  dns {
        proxy_enabled = true
        servers       = []
        }

  tags = var.project_tags
}

#---------------------------------------
# Azure Firewall
#---------------------------------------
resource "azurerm_firewall" "firewall" {
  name                = local.firewall
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku_tier
  ip_configuration {
    name                 = "afw-ipconfig"
    subnet_id            = azurerm_subnet.snet-firewall.id
    public_ip_address_id = azurerm_public_ip.pip-firewall-primary.id
  }
  firewall_policy_id = azurerm_firewall_policy.afw-policy-01.id

  tags  = var.project_tags

  depends_on = [azurerm_firewall_policy.afw-policy-01]
}