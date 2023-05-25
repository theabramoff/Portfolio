
# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "tf-rg" {
    name     = "rg-az01-abramov-terraform-test"
    location = "westeurope"

    tags = {
        Description = "new RG for terraform"
        OwnedBy = "Abramov, Andrey"
    }
}