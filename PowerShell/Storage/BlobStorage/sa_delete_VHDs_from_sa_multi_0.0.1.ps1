#########################################
# Az module required
# The scripts deletes unlock VHDs (from classic VMs) from Storage Accounts within all subscriptions
# The script can be used for cost-optimization after migration from ASM to ARM 
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file="c:\temp\Azure-StorageAccaunt_VHDs_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 
#start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# Set deleteUnattachedVHDs=1 if you want to delete unattached VHDs
# Set deleteUnattachedVHDs=0 if you want to see the Uri of the unattached VHDs
$deleteUnattachedVHDs=1
$array = @()
$status = "deleted"

$subscriptions = (Get-AzSubscription).Name
#$subscriptions = "Sub1", "Sub2", "Sub3", "< ... >", "SubN+1"
    Foreach ($subscription in $subscriptions)
    {
        Select-AzSubscription $subscription 
            $StorageAccounts = Get-AzStorageAccount
                foreach($storageAccount in $storageAccounts)
                {
                $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $StorageAccount.ResourceGroupName -Name $StorageAccount.StorageAccountName)[0].Value
                $context = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey $storageKey
                $containers = Get-AzStorageContainer -Context $context
                    foreach($container in $containers)
                    {
                    $blobs = Get-AzStorageBlob -Container $container.Name -Context $context
                    #Fetch all the Page blobs with extension .vhd as only Page blobs can be attached as disk to Azure VMs
                    $Blobz = $blobs | Where-Object {$_.BlobType -eq 'PageBlob' -and $_.Name.EndsWith('.vhd') }
                        foreach ($blob in $blobz)
                        {
                            If ($blob.ICloudBlob.Properties.LeaseStatus -eq 'Unlocked')
                                {
                                if($deleteUnattachedVHDs -eq 1)
                                        {
                                    Write-Host "Deleting unattached VHD  $blob.name"
                                    #$blob.ICloudBlob.Uri.AbsoluteUri | Remove-AzStorageBlob -Force
                                    $blob | Remove-AzStorageBlob -Force       
                                    Write-Host "Deleted unattached VHD  $blob.ICloudBlob.Uri.AbsoluteUri"                 
                                    #$size = $blob.Length 
                                    $array += New-Object PSObject -Property @{Subscription = $subscription; StorageAccount = $storageAccount.StorageAccountName; Blob = $blob.ICloudBlob.Uri.AbsoluteUri; Name = $blob.name; Size=[math]::round($blob.Length/1GB, 2); Status=$status}
                                        }
                                        else{
                                                Write-Host "no blobs found to delete "
                                            }
                                } 
                    }
                }
            }
     }

$array | Export-Csv -NoTypeInformation -Path $file
Write-Host "Storage list is written to the  $file"
#stop timer
$watch.Stop()
Write-Host $watch.Elapsed