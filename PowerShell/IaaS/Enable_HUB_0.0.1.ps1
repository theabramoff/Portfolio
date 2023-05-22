#########################################
# Az module required
# The script enables Azure Hybrid Benefit for Windows Servers
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file="< ... >\Azure-HUB" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 

Connect-AzAccount

$Subscriptions = Get-AzSubscription

foreach ($Subscription in $Subscriptions) 
{
(Select-AzSubscription $Subscription).Subscription.Name

Get-AzVm -Status | Where-Object {$_.StorageProfile.OsDisk.OsType -eq "Windows" -and $_.LicenseType -ne "Windows_Server" -and $_.Powerstate -eq "VM running" } | Select-Object -Property Name, @{Label="VmSize";Expression={$_.HardwareProfile.VmSize}}, @{Label="OsType";Expression={$_.StorageProfile.OsDisk.OsType}}, @{Label="PowerState";Expression={$_.PowerState}} | Format-Table >> $file

foreach ($vm in $VMsWithoutAHB)

{
    $name = $vm.name
    $rg = $vm.ResourceGroupName

    Write-Host 'Enabling Azure Hybrid Benefit on VM: ' + $name
    $vm.LicenseType = "Windows_Server"
    Update-AzVM -ResourceGroupName $rg -VM $vm
   
}
}
