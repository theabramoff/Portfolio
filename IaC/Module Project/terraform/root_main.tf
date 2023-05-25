# Configure the Microsoft Azure Provider
# Declaration for local provider name "azurerm" in module.resources
provider "azurerm" {
    alias = "resources"
    skip_provider_registration = "true"
    features {}
    # replace < ... > with your subscription ID ########-####-####-####-############
    subscription_id = "< ... >"
    # the variables below are specified in Azure pipelines, refer to Azure Key Vault Secrets
    client_id       = var.spn-client-id
    client_secret   = var.spn-client-secret
    tenant_id       = var.spn-tenant-id
}

module "resources" {

  providers = {
    azurerm = azurerm.resources
  }

  source = "./resources"
}