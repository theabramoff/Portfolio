#########################################
# Az module required
# The script sets up lifecycle management and simple blob protection over a storage account in single subscription
# Az.DataProtection required - https://www.powershellgallery.com/packages/Az.DataProtection/0.4.0
# https://learn.microsoft.com/en-us/azure/backup/backup-blobs-storage-account-ps
#########################################

# Authenticate Azure portal
Connect-AzAccount

# Initialize the following variables with your values
# Replace < ... > with rg name
$rgName = "< ... >"
# Replace < ... > with sa name
$accountName = "< ... >"

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# Enable Access tracking 
Enable-AzStorageBlobLastAccessTimeTracking  -ResourceGroupName $rgName -StorageAccountName $accountName -PassThru
# Enable container soft delete 
Enable-AzStorageContainerDeleteRetentionPolicy -ResourceGroupName $rgName -StorageAccountName $accountName -RetentionDays 30
# Enable blob soft delete
Enable-AzStorageBlobDeleteRetentionPolicy -ResourceGroupName $rgName -StorageAccountName $accountName -RetentionDays 30

# Create a new action object for BaseBlobAction
$action = Add-AzStorageAccountManagementPolicyAction -EnableAutoTierToHotFromCool -BaseBlobAction TierToCool -DaysAfterLastAccessTimeGreaterThan 365
Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToArchive -DaysAfterModificationGreaterThan 365 -InputObject $action

# Create a new action object for BlobVersionAction
Add-AzStorageAccountManagementPolicyAction -BlobVersionAction Delete -DaysAfterCreationGreaterThan 90 -InputObject $action

# Create a new filter object.
$filter = New-AzStorageAccountManagementPolicyFilter -BlobType blockBlob

# Create a new rule object.
$rule1 = New-AzStorageAccountManagementPolicyRule -Name standard-lifecycle-rule -Action $action -Filter $filter

# Create the policy.
Set-AzStorageAccountManagementPolicy -ResourceGroupName $rgName -StorageAccountName $accountName -Rule $rule1
