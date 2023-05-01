# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with the vault name
$vault = "< ... >"
# Replace < ... > with the server name
$server = "< ... >"

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file="< ... >\Azure-backups_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()
#Get all subscriptions
$subs = (Get-AzSubscription).Name
#Create an array = 0
$array = @()

foreach ($sub in $subs)

{

Select-AzSubscription $sub
#Write-Host "now we are in" $sub
#Write-Host

# Replace < ... > with the backup vault mask, e.g. "bckp-"
$vaults = Get-AzRecoveryServicesVault | where name -Match "< ... >" 
$vms = (Get-AzVM).Name

foreach ($vault in $vaults)

{
#Write-Host "now we are in" $vault.Name
#Write-Host
    Foreach ($vm in $vms)
    {   

         if ($vm.Location -ne $vault.Location) 
         {
           #  Write-Host "working on $VM"
            # Write-Host
             If ((Get-AzRecoveryServicesBackupContainer -VaultId $vault.id -FriendlyName $vm  -ContainerType AzureVM -BackupManagementType AzureVM -Status Registered) -ne $null)
             {
             $container = (Get-AzRecoveryServicesBackupContainer -VaultId $vault.id -FriendlyName $vm  -ContainerType AzureVM -BackupManagementType AzureVM ) | select -First 1
             $backupitem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vault.id
             $policy = ($backupitem).ProtectionPolicyName 
             $array += New-Object PSObject -Property @{VM = $vm; Subscription= $sub; Vault= $vault.Name;  Policy = $policy }
             }
               # else
              #  {
               # Write-Host "$vm doesn't exist in" $vault.name
              #  Write-Host
              #  }
        }
            else
            {
           # Write-Host "$vm doesn't exist in" $vault.name
            #Write-Host

             $array += New-Object PSObject -Property @{VM = "$vm"; Subscription= "$sub"; Policy = "not exist" }

            }
    }
}

}
$array | Export-Csv -NoTypeInformation -Path $file
Write-Host "VM list is written to the  $file"


$watch.Stop()
Write-Host $watch.Elapsed
