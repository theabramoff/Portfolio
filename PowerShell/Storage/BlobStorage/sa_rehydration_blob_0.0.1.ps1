#########################################
# Az module required
# The script allows to rehydrade blobs fron archive to hot in single subscription
#########################################

# Authenticate Azure portal
Connect-AzAccount
# Replace < ... > with storage name
$storageAccountName = "< ... >"
# Replace < ... > with container name
$containerName = "< ... >"
# Replace < ... > with sa access key
$key = "< ... >"

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

$blobs = Get-AzStorageBlob -Context $(New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key ) -Container $containerName

foreach ($blob in $blobs) {
    if ($blob.ICloudBlob.Properties.StandardBlobTier -eq "Archive") {
        $blob.ICloudBlob.SetStandardBlobTier("Hot", "Standard")
    }
    else {
        $blob.ICloudBlob.SetStandardBlobTier("Hot")
    }
    write-host $blob.name "is moved to rehydration"
}
