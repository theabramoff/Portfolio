#########################################
# Az.Reservations module required
#########################################

# Authenticate Azure portal
Connect-AzAccount
# Replace < ... > to AAD group
$Group = Get-AzADGroup -SearchString "< ... >"
# adddays(-10) - will apply changes for all the reserved instances purchised <= 10 days. e.g. if need to take scope for all reservations are being purchised for last year, then adddays(-365)
Get-AzReservationOrder | Where-Object {($_.ProvisioningState -eq "Succeeded") -and ($_.RequestDateTime -gt (get-date).adddays(-10))} | New-AzRoleAssignment -ObjectId $Group.Id -RoleDefinitionName Owner -Scope {$_.Id}
