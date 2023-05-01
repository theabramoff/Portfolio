#########################################
# Az module required
# The script dumps Windows servers with disabled Azure Hybrid Benefit feature
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

(Select-AzSubscription "$Subscription").Subscription.Name

Get-AzVM -Status | Where-Object {$_.StorageProfile.OsDisk.OsType -eq "Windows" -and $_.LicenseType -ne "Windows_Server" -and $_.Powerstate -eq "VM running" } | Select-Object -Property Name, @{Label="VmSize";Expression={$_.HardwareProfile.VmSize}}, @{Label="OsType";Expression={$_.StorageProfile.OsDisk.OsType}}, @{Label="PowerState";Expression={$_.PowerState}} | Format-Table >> $file

}

