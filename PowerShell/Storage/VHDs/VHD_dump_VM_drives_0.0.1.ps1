#########################################
# Az module required
# the script dumps VHDs from a VM within all subscriptions and uploads to csv
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file="< ... >\Azure-ARM-VMs_drives" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 
# Start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()
# Authenticate Azure portal
Connect-AzAccount
#Get all subscriptions
$subs = (Get-AzSubscription).Name
#Create an array = 0
$array = @()
# get a subscriptions from all subscriptions 
Foreach ($sub in $subs)
{
#select subscription
#(Select-AzSubscription $sub).silence
Select-AzSubscription $sub

#get all VMs in subscription
$VMs= (Get-AzVM).Name

    # get a VM from all VMs 
    Foreach ($VM in $VMs)
        {
    Write-Host "Working on $VM"

    # Condition - if OS Discr is managed - RUN
    if ((Get-azvm -name $VM).StorageProfile.OsDisk.ManagedDisk -ne $null) 
        {
        $DriveCapacity = (Get-AzDisk | where ManagedBy -Match $VM | select DiskSizeGB | Measure-Object -sum DiskSizeGB).Sum
    #Write-host "$VM drives capacity is $DriveCapacity"
        $array += New-Object PSObject -Property @{VM = "$VM"; Subscription= "$Sub"; DrivesCapacity = $DriveCapacity; Type= "managed" }
        }
        # if OS disk is not managed - run
        Else
                {
                    $OSDriveUnm = ((Get-AzVM -Name $vm).StorageProfile.OsDisk | select DiskSizeGB | Measure-Object -Sum DiskSizeGB).sum
                    $DataDisksUnm = ((Get-AzVM -Name $vm).StorageProfile.DataDisks | select DiskSizeGB | Measure-Object -Sum DiskSizeGB).sum
                    $DriveCapacity = $OSDriveUnm+$DataDisksUnm
                    #Write-host "$VM drives capacity is $DriveCapacity"
                    $array += New-Object PSObject -Property @{VM = "$VM"; Subscription= "$Sub"; DrivesCapacity = $DriveCapacity; Type= "unmanaged"}
                }
            }
}

$array | Export-Csv -NoTypeInformation -Path $file
Write-Host "Drive list is written to the  $file"
# Stop timer
$watch.Stop()
Write-Host $watch.Elapsed

