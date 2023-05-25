# Replace < ... > with storage account name where tf state will be stored and where Azure pipelines have access , e.g. satrfmstat
terraform {
  backend "azurerm" {
    storage_account_name    = "< ... >"
    container_name          = "terraform-state"
    key                     = "tf-state.tfstate"
  }
}
