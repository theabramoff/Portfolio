#########################################
# The script creates custom role for Azure Data Factory from Reader role
#########################################

$role = get-AzRoleDefinition -Name 'reader'
$role.id = $null
$role.name = 'Azure Data Factory Operators (custom)'
$role.Description = "Can run, resume and cancel ADF pipelines and triggers."
$role.actions.clear()
$role.Actions.add("Microsoft.DataFactory/factories/pipelines/createrun/action")
$role.Actions.add("Microsoft.DataFactory/datafactories/datapipelines/resume/action")
$role.Actions.add("Microsoft.DataFactory/factories/pipelineruns/cancel/action")
$role.Actions.add("Microsoft.Resources/deployments/write")
$role.Actions.add("Microsoft.DataFactory/factories/triggers/write")
$role.Actions.add("Microsoft.DataFactory/factories/triggers/stop/action")
$role.Actions.add("Microsoft.DataFactory/factories/triggers/start/action")
$role.AssignableScopes.clear()
# Replace < ... > with subscription ID
$role.AssignableScopes.add("/subscriptions/< ... >")
New-AzRoleDefinition -Role $role