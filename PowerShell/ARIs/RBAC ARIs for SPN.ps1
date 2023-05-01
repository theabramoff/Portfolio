#########################################
# Az.Reservations module required
#########################################

# Authenticate Azure portal
Connect-AzAccount
# Replace < ... > to SPN name, e.g. my-app-spn
$id = (Get-AzADServicePrincipal | Where-Object DisplayName -Like "< ... >").Id
# adddays(-10) - will apply changes for all the reserved instances purchised <= 10 days. e.g. if need to take scope for all reservations are being purchised for last year, then adddays(-365)
Get-AzReservationOrder | Where-Object {($_.ProvisioningState -eq "Succeeded") -and ($_.RequestDateTime -gt (get-date).adddays(-10))} | New-AzRoleAssignment -ObjectId $id -RoleDefinitionName Reader -Scope {$_.Id}
