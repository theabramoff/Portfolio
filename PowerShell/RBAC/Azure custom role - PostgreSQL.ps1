#########################################
# The script creates custom role for Azure Postgre SQL from Reader role
#########################################

$role = get-AzRoleDefinition -Name 'reader'
$role.id = $null
$role.name = 'Azure Postgre SQL Operators (custom)'
$role.Description = "Can administrate Azure Postgre SQL."
$role.actions.clear()
$role.Actions.add("Microsoft.DBforPostgreSQL/flexibleServers/write")
$role.Actions.add("Microsoft.DBforPostgreSQL/flexibleServers/delete")
$role.Actions.add("Microsoft.Resources/deployments/validate/action")
$role.Actions.add("Microsoft.Resources/deployments/write")
$role.Actions.add("Microsoft.DBforPostgreSQL/servers/delete")
$role.Actions.add("Microsoft.DBforPostgreSQL/servers/read")
$role.Actions.add("Microsoft.DBforPostgreSQL/servers/write")
$role.AssignableScopes.clear()
# Replace < ... > with subscription ID
$role.AssignableScopes.add("/subscriptions/< ... >")
New-AzRoleDefinition -Role $role