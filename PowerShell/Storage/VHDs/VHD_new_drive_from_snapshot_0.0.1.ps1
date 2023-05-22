#########################################
# Az module required
# the script deployes a single VHD in a single subscription
#########################################

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

#Enter name of the ResourceGroup in which you have the snapshots
# Replace < ... > with rg name
$resourceGroupName ="< ... >"

#Enter name of the snapshot that will be used to create Managed Disks
# Replace < ... > with snapshot name
$snapshotName = "< ... >"

#Enter name of the Managed Disk
# Replace < ... > with new VHD name
$diskName = "< ... >"

#Enter size of the disk in GB
# Replace < ... > with volume in GB
$diskSize = "< ... >"

#Enter the storage type for Disk. PremiumLRS / StandardLRS.
# Replace < ... > with tier
$storageType = "< ... >"

#Enter the Azure region where Managed Disk will be created. It should be same as Snapshot location, e.g. 'West Europe'
# Replace < ... > with region
$location = "< ... >"

#Set the context to the subscription Id where Managed Disk will be created
#Select-AzSubscription -SubscriptionId '<Subscription ID>'

#Get the Snapshot ID by using the details provided
$snapshot = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName 

#Create a new Managed Disk from the Snapshot provided 
$diskConfig = New-AzDiskConfig -SkuName $storageType -DiskSizeGB $diskSize -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id

New-AzDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $diskName | Out-Null   
