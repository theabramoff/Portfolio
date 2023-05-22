#########################################
# Az module required
# the scripts dumps VHDs (from classic VMs) from Storage Accounts
# the script can be used for cost-optimization after migration from ASM to ARM 
#########################################

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

$array = @()
# Replace < ... > with sa name
$StorageAccountName = "< ... >"
    $storageAccount = Get-AzStorageAccount | Where-Object StorageAccountName -Like $StorageAccountName
    $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName)[0].Value
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
            $name = $blob.name
            $size = $blob.Length 
            $array += New-Object PSObject -Property @{Name = $name; Size=[math]::round($size/1GB, 2)}
            }

        } 
       
    }

