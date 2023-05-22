#########################################
# Az module required
# the script dumps VHD by a mask within all subscriptions and uploads to csv within all subscriptions
# e.g. if vhd includes word 'backup' then this drive will be deleted
#########################################

$mask = "backup"
# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$file="< ... >\Azure-dump_" + ($mask) + "_drives_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 
#start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()
$array = @()
$subsriptions = (Get-AzSubscription).Name

Foreach ($subsription in $subsriptions)
{
Select-AzSubscription $subsription

$VMs = (Get-AzVM).Name

foreach ($vm in $VMs)

    {

    
        $drive = ((Get-AzVM -Name $vm ).StorageProfile.DataDisks | Where-Object name -Match "backup").name
        
            If  ($null -ne $drive)
            {
            $array += New-Object PSObject -Property @{Subsctiption="$subsription"; VM = "$vm"; Drive="$drive"}
            }
     }
    
 }
    
$array | Export-Csv -NoTypeInformation -Path $file
    Write-Host "Drive list is written to the  $file"

#stop timer
$watch.Stop()
Write-Host $watch.Elapsed