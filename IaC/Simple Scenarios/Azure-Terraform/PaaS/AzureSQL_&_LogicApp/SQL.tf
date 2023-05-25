
# replace administrator_password with < ... > with password
resource "azurerm_sql_server" "tf-sql" {
  name                         = var.sql
  resource_group_name          = azurerm_resource_group.tf-rg.name
  location                     = azurerm_resource_group.tf-rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "< ... >"

  tags                         = var.tags
}

resource "azurerm_sql_database" "tf-sqldb-01" {

  count = 2

  name                = "${var.sqldb}${count.index + 1}"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  server_name         = azurerm_sql_server.tf-sql.name

  tags                = var.tags

}