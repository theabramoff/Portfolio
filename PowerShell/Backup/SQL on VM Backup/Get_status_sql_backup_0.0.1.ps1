#########################################
# Az module required
# this script provides status on SQL backup from RSV
#########################################

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# Replace < ... > with the vault name
$vault = "< ... >"
$targetVault = Get-AzRecoveryServicesVault -name $vault
$bkpItems = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureWorkload -WorkloadType MSSQL -VaultId $targetVault.ID
$bkpItems | sort ProtectionStatus >> "c:\temp\sqlbackup.txt"