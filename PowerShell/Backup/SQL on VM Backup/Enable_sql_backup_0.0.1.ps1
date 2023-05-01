#########################################
# Az module required
# this script enables SQL backup from RSV
#########################################

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# Replace < ... > with the vault name
$vault = "< ... >"
# Replace < ... > with the server name
$server = "< ... >"
# Replace < ... > with the policy name
$policyName = "< ... >"

$targetVault = Get-AzRecoveryServicesVault -name $vault
Set-AzRecoveryServicesVaultContext -Vault $targetVault
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyName

$bkpItems = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureWorkload -WorkloadType MSSQL -VaultId $targetVault.ID | Where-Object servername -Like $server

Foreach ($bkpItem in $bkpItems) {

Enable-AzRecoveryServicesBackupProtection -Item $bkpItem -Policy $policy 

Write-Host $bkpItem "enabled"
}

