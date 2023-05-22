#########################################
# Az module required
# the script dumps unattached VHS within all subscriptions and uploads to csv
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file="< ... >\Azure-Unattached_Drives" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 

# Authenticate Azure portal
Connect-AzAccount
$subscriptions = Get-AzSubscription

Foreach ($subscription in $subscriptions)
{
    (Select-AzSubscription "$Subscription").Subscription.Name
    Get-AzDisk |  Where-Object {($_.DiskState -eq 'unattached') -and ($_.ManagedBy -eq $null) } | Select-Object ResourceGroupName, Name, DiskState, Tags | Format-Table >> $file
}

