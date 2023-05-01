# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

$vaults = Get-AzRecoveryServicesVault

foreach ($vault in $vaults)

{
    $VMs = (Get-AzVM).Name
    Foreach ($vm in $VMs)
    {   
    Write-Host "working on $VM in $vault.name"
    $Container = (Get-AzRecoveryServicesBackupContainer -VaultId $vault.id -FriendlyName $vm  -ContainerType AzureVM -BackupManagementType AzureVM ).silence
     
        If ( $Container -ne $null)
        {
        $backupitem = Get-AzRecoveryServicesBackupItem -Container $Container -WorkloadType AzureVM -VaultId $vault.id
        $backupitem | select name , ProtectionPolicyName | fl
        }
            else
            {
            Write-Host "$VM doesn't exist in $vault.name"
            }
    }
}
