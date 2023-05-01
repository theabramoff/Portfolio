#########################################
# Az module required
# this script simply dumps all compute instances from azure portal within all subscriptions
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file="< ... >\Azure-ARM-VMs_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 

Connect-AzAccount 
$subs = Get-AzSubscription 

$vmobjs = @()

foreach ($sub in $subs)
{
    
    Write-Host Processing subscription $sub.Subscription

    try
    {

        Select-AzSubscription -SubscriptionId $sub.SubscriptionId -ErrorAction Continue

        $vms = Get-AzVM -Status

        foreach ($vm in $vms)
        {
            $vmInfo = [pscustomobject]@{
                'Subscription'=$sub.Name
                'Mode'='ARM'
                'Name'=$vm.Name
                'ResourceGroupName' = $vm.ResourceGroupName
                'Location' = $vm.Location
                'VMSize' = $vm.HardwareProfile.VMSize
                'Status' = $vm.PowerState
                'OS' = $vm.StorageProfile.OsDisk.OsType
                
                 }

            $vmobjs += $vmInfo

        }  
    }
    catch
    {
        Write-Host $error[0]
    }
}

$vmobjs | Export-Csv -NoTypeInformation -Path $file
Write-Host "VM list written to $file"

