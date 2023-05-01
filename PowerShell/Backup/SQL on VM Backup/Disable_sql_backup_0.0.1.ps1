#########################################
# Az module required
# this script disables SQL backup from RSV
#########################################

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# Replace < ... > with the vault name
$vault = "< ... >"
# Replace < ... > with the server name
$server = "< ... >"

$targetVault = Get-AzRecoveryServicesVault -name $vault

$bkpItems = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureWorkload -WorkloadType MSSQL -VaultId $targetVault.ID | Where-Object servername -Like $server

Foreach ($bkpItem in $bkpItems) {
Disable-AzRecoveryServicesBackupProtection -Item $bkpItem -VaultId $targetVault.ID -Force
Write-Host $bkpItem "disabled"
}