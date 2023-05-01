#########################################
# Az module required
# this script deployes a VM from existing VM, in other words - cloning a VM in existing vnet/snet
# note: 
# 1. Original VM is a source VM - it has to be stopped (deallocated) before execution
# 2. vNet and NSG for cloning have to be pre-created
# Steps:
# 1. Specify parameters
# 2. Make sure that an original VM is diallocated
# 3. Run the script in several steps and follwo the sequence
# 4. Start the original VM
# 5. Crosscheck 
#########################################

# start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

# Authenticate Azure portal
Connect-AzAccount

#-------------
# Subscription 
# Replace < ... > with rg name
$subscriptionID = "< ... >"

# Replace < ... > with subscription name
Select-AzSubscription $subscriptionID

###########################################
#-------------Parameters----------------#

#-------------Original VM config----------------#
# original VM name
$originalVM = "< ... >"
# new vm for deployment
# Replace < ... > with VM names VM1, VM2, etc
$newVMs = '< ... >','< ... >','< ... >','< ... >','< ... >','< ... >','< ... >'
#-------------
# original RG name
# Replace < ... > with rg name
$resourceGroupName = "< ... >"
# original location
# Replace < ... > with location, e.g. westeurope
$location = "< ... >"
# original location
# Replace < ... > with VM SKU, e.g. Standard_E2s_v3
$vmSKU = "< ... >"

#-------------New cloned VM config----------------#

# vNet for Clone VM
# Replace < ... > with vNet for cloning
$vNetExternalName = "< ... >"
$vNetExternal = Get-AzVirtualNetwork -Name $vNetextErnalname
# Replace < ... > with NSG for cloning
$NSGname = "< ... >"
$nsg = Get-AzNetworkSecurityGroup -name $NSGname

#-------------Snapshots----------------#

# OS drive snapshot name to be given 
$Os_Drive_snap = "< ... >" 
# Data01 drive snapshot name to be given 
$Data_Drive01_snap = "< ... >"
# Data02 drive snapshot name to be given 
$Data_Drive02_snap = "< ... >"

#-------------Target Drives----------------#
# original OS drive name
$Os_Drive = "< ... >" 
# original Data01 drive name
$Data01_Drive = "< ... >" 
# original Data02 drive name
$Data02_Drive = "< ... >"

#select target VM
$vm = Get-AzVM `
-ResourceGroupName $resourceGroupName `
-Name $originalVM

#config of OS snapshot
$snapshot_OS =  New-AzSnapshotConfig `
-SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
-Location $location `
-CreateOption copy

#config of Data01 snapshot
$snapshot_data01 =  New-AzSnapshotConfig `
-SourceUri /subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/disks/$Data01_Drive `
-Location $location `
-CreateOption copy

# config of Data02 snapshot
$snapshotDataDrive =  New-AzSnapshotConfig `
-SourceUri /subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/disks/$Data02_Drive `
-Location $location `
-CreateOption copy

# creation of OS snapshot
write-host "working on" ${Os_Drive_snap}
New-AzSnapshot `
-Snapshot $snapshot_OS `
-SnapshotName $Os_Drive_snap `
-ResourceGroupName $resourceGroupName 

# creation of Data01 snapshot
write-host "working on" ${Data_Drive01_snap}
New-AzSnapshot `
-Snapshot $snapshot_data01 `
-SnapshotName $Data_Drive01_snap `
-ResourceGroupName $resourceGroupName 

# creation of Data02 snapshot
write-host "working on" ${$Data_Drive02_snap}
New-AzSnapshot `
-Snapshot $snapshotDataDrive `
-SnapshotName $Data_Drive02_snap `
-ResourceGroupName $resourceGroupName 

# For each VM in VMs do the following
foreach ($VM in $newVMs) {

write-host "working on" ${VM}

# PIP for Clone VM
$ipName = "pip-${VM}"
write-host "deploying pip-${VM}"
$pip = New-AzPublicIpAddress `
-Name $ipName -ResourceGroupName $resourceGroupName `
-Location $location `
-AllocationMethod Static

# NIC for clone VM
$nicName = "nic-${VM}"
write-host "deploying nic-${VM}"
$nic = New-AzNetworkInterface -Name $nicName `
-ResourceGroupName $resourceGroupName `
-Location $location -SubnetId $vNetExternal.Subnets[0].Id `
-PublicIpAddressId $pip.Id `
-NetworkSecurityGroupId $nsg.Id

# Set the VM name and size
$vmConfig = New-AzVMConfig -VMName $VM -VMSize $vmSKU

#-------------New Drives for CloneVM----------------#
# storage type for new drives
$SnapshotStorageType = 'Standard_LRS'
# storage type for new drives
$DriveStorageType = 'Premium_LRS'
# New OS drive name
$Clone_Os_Drive = "vhd-${VM}-OsDisk"
# New Data drive 01 name
$Clone_Data01_Drive = "vhd-${VM}-data-01"
# New Data drive 02 name
$Clone_Data02_Drive = "vhd-${VM}-data-02"

###########################################

#creation of OS Drive from snapshot
$DriveSnap_OS = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $Os_Drive_snap
$diskConfig_OS = New-AzDiskConfig -SkuName $SnapshotStorageType -Location $location -CreateOption Copy -SourceResourceId $DriveSnap_OS.Id
write-host "deploying $Clone_Os_Drive"
$osDisk = New-AzDisk -Disk $diskConfig_OS -ResourceGroupName $resourceGroupName -DiskName $Clone_Os_Drive

#creation of Data01 Drive from snapshot
$Drive01Snap = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $Data_Drive01_snap
$diskConfig_data01 = New-AzDiskConfig -SkuName $SnapshotStorageType -Location $location -CreateOption Copy -SourceResourceId $Drive01Snap.Id
write-host "deploying $Clone_Data01_Drive"
$Data01Disk =  New-AzDisk -Disk $diskConfig_data01 -ResourceGroupName $resourceGroupName -DiskName $Clone_Data01_Drive

#creation of Data02 Drive from snapshot
$Drive02Snap_Data = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $Data_Drive02_snap
$diskConfig_Data02 = New-AzDiskConfig -SkuName $SnapshotStorageType -Location $location -CreateOption Copy -SourceResourceId $Drive02Snap_Data.Id
write-host "deploying $Clone_Data02_Drive"
$Data02Disk = New-AzDisk -Disk $diskConfig_Data02 -ResourceGroupName $resourceGroupName -DiskName $Clone_Data02_Drive

################Deployment ################

# Add the NIC to CloneVM
$CloneVM = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Add the OS disk to the CloneVM
$CloneVM = Set-AzVMOSDisk -VM $CloneVM -ManagedDiskId $osDisk.Id -StorageAccountType $DriveStorageType -CreateOption Attach -Windows
# Add the Data01 disk to the CloneVM
$CloneVM = Add-AzVMDataDisk -VM $CloneVM -name $Data01Disk.name -ManagedDiskId $Data01Disk.id  -StorageAccountType $DriveStorageType -CreateOption Attach -Lun 0 -Caching None
# Add the Data disk to the CloneVM
$CloneVM = Add-AzVMDataDisk -VM $CloneVM -name $Data02Disk.name -ManagedDiskId $Data02Disk.id -StorageAccountType $DriveStorageType -CreateOption Attach -Lun 1 -Caching ReadOnly
# Deployment of CloneVM
write-host "deploying" ${CloneVM}
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $CloneVM

}
# stop timer
$watch.Stop() 
Write-Host $watch.Elapsed

#---------------------------------------
#
#
#
#
#
#
#
#
#
#
#  do not run the part below till servers are in domain
#
#
#
#
#
#
#
#
#
#
#---------------------------------------

# start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

# For each VM in VMs do the following
foreach ($VM in $newVMs) {

# Stop-AzVM -ResourceGroupName $resourceGroupName -Name $VM -Force

# giving time to delete VM
write-host "waiting 60 seconds to make sure ${VM} is deallocated"
Start-Sleep -Seconds 60

# removing VM in an external VM
write-host "removing ${VM}"
Remove-AzVM -ResourceGroupName $resourceGroupName -Name $VM -Force

# giving time to delete VM
write-host "waiting 120 seconds to make sure ${VM} is deleted"
Start-Sleep -Seconds 120

# removing external VM's NIC
write-host "removing nic-${VM}"
Remove-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name "nic-${VM}" -Force

# removing external VM's PIP
write-host "removing pip-${VM}"
Remove-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name "pip-${VM}" -Force

}
# stop timer
$watch.Stop() 
Write-Host $watch.Elapsed

#---------------------------------------
#
#
#
#
#
#
#
#
#
#
#  do not run the part below till external servers are not deleted
#
#
#
#
#
#
#
#
#
#
#---------------------------------------

# start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

# vNet for Clone VM
$vNetInternalName = "< ... >"
$vNetInternal = Get-AzVirtualNetwork -Name $vNetInternalName

# For each VM in VMs do the following
foreach ($VM in $newVMs) {

write-host "working on" ${VM}

write-host "deploying NIC on" ${VM}
# NIC for clone VM
$nicName = "nic-${VM}"
$nic = New-AzNetworkInterface -Name $nicName `
-ResourceGroupName $resourceGroupName `
-Location $location -SubnetId $vNetInternal.Subnets[0].Id


# Set the VM name and size
$InternaVMconfig = New-AzVMConfig -VMName $VM -VMSize $vmSKU

###########################################

$ExistingOSdisk = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName "vhd-${VM}-OsDisk"
$ExistingData01disk = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName "vhd-${VM}-data-01"
$ExistingData02disk = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName "vhd-${VM}-data-02"

################Deployment ################

# Add the NIC to CloneVM
$NewInternalVM = Add-AzVMNetworkInterface -VM $InternaVMconfig -Id $nic.Id

# Add the OS disk to the CloneVM
$NewInternalVM = Set-AzVMOSDisk -VM $NewInternalVM -ManagedDiskId $ExistingOSdisk.Id -StorageAccountType $DriveStorageType -CreateOption Attach -Windows
# Add the Data01 disk to the CloneVM
$NewInternalVM = Add-AzVMDataDisk -VM $NewInternalVM -name $ExistingData01disk.name -ManagedDiskId $ExistingData01disk.id  -StorageAccountType $DriveStorageType -CreateOption Attach -Lun 0 -Caching None
# Add the Data02 disk to the CloneVM
$NewInternalVM = Add-AzVMDataDisk -VM $NewInternalVM -name $ExistingData02disk.name -ManagedDiskId $ExistingData02disk.id -StorageAccountType $DriveStorageType -CreateOption Attach -Lun 1 -Caching ReadOnly
# Deployment of CloneVM
write-host "deploying" ${VM}
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $NewInternalVM

}
# stop timer
$watch.Stop() 
Write-Host $watch.Elapsed

################ Junk removal ################
# start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

# delition of OS snapshot
Remove-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $Os_Drive_snap -Force

# delition of Data01 snapshot
Remove-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $Data_Drive01_snap -Force

# delition of Data02 snapshot
Remove-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $Data_Drive02_snap -Force

# stop timer
$watch.Stop() 
Write-Host $watch.Elapsed