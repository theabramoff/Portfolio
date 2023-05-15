#########################################
# Az module required
# this script deployes a VM from existing VM, in other words - cloning a VM in existing vnet/snet
# note: 
# 1. target VM is a source VM - it has to be stopped (deallocated) before execution
# 2. in both VMs - original and new will be in same domain , then newly deployed VM has to be re-joined to the domain with a different name
# Steps:
# 1. Specify parameters
# 2. Make sure that an original VM is diallocated
# 3. Run the script
# 4. Update domain name if needed
# 5. Start the original VM
# 6. Crosscheck 
#########################################

# start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

###########################################
#-------------<Parameters block>----------------#

#-------------Target VM config - VARIABLES to be set up----------------#

# target RG name
# Replace < ... > with rg name
$resourceGroupName = "< ... >"

# target VM name
# Replace < ... > with current vm name
$originalVM = "< ... >"

# new VM name
# Replace < ... > with new vm name
$newVM = "< ... >"

# specify operational status, e.g. sbx, dev, prd
# Replace < ... > with desired operational status
$oper_status = "< ... >"

# new RG name
$newresourceGroupName = "rg-$newVM-$oper_status"

# tags
# Replace < ... > with new tags defentitions
$ITOwnerGroup = "< ... >"
$Ownedby = "< ... >"
$OwnerBackupPerson = "< ... >"
$Description = "[$oper_status] - < ... >"
$Region = "< ... >"
$LifecycleEnd = "< ... >"
$OperationalStatus = $oper_status

# target location, e.g. westeurope
# Replace < ... > with region
$location = "< ... >"

# vm size, e.g. Standard_E2s_v3
# Replace < ... > with desired VM SKU
$vmSize = "< ... >"

# storage type for new drives, e.g. Standard_LRS
# Replace < ... > with desired storage tier
$storageType = "< ... >"

# sNet / sNet & IP (optional)
# Replace < ... > with existing vnet
$vNet_name = "< ... >"
# Replace < ... > with existing snet
$sNet_name = "< ... >" 
# Replace < ... > with IP fron the snet
$IP = "< ... >" #Set up IP if needed from a snet range

# storage account for diagnostics and its RG
# Replace < ... > with sa and sa's rg name
$storage_account_rg = "< ... >"
$storage_account = "< ... >"

# backup set up
# Replace < ... > with backup vault and policy
$backup_vault = "< ... >"
$policy_name = "< ... >"


#-------------Target Drives----------------#
# OS drive name
# Replace < ... > with existing OS Drive
$Os_Drive = "< ... >"

# Data drive 01 name
# Replace < ... > with existing Data Drive
$Data_01 = "< ... >"

# Data drive 02 name
# Replace < ... > with existing Data Drive
$Data_02 = "< ... >"

#-------------< / Parameters block>----------------#
###########################################


#-------------Snapshots of the target VM----------------#

#OS drive snapshot
$Os_Drive_snap = "vhd-$originalVM-OsDisk-snapshot"

#Data drive 01 snapshot
$Data_01_snap = "vhd-$originalVM-Disk-01-snapshot"

#Data drive 02 snapshot
$Data_02_snap = "vhd-$originalVM-Disk-02-snapshot"

#-------------New Drives for the new VM----------------#

#OS drive snapshot
$Os_Drive_new = "vhd-$newVM-OsDisk"

#Data drive 01 snapshot
$Data_01_new = "vhd-$newVM-Disk-01"

#Data drive 02 snapshot
$Data_02_new = "vhd-$newVM-Disk-02"

####################New RG creation#######################

New-AzResourceGroup -Name $newresourceGroupName -Location $location -Tag @{
'IT Owner Group' = $ITOwnerGroup; 
'OwnedBy' = $Ownedby; 
'Owner Backup Person' = $OwnerBackupPerson; 
'Description' = $Description; 
'Region' = $Region;
'Lifecycle End' = $LifecycleEnd;
'OperationalStatus' = $OperationalStatus;
}


####################Snapshots creation#######################

#select target VM
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $originalVM

#config of OS snapshot
$config_snapshot_OS =  New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy

#config of Data01 snapshot
$DataDisk_01_ID = (Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $Data_01).Id
$config_snapshot_Data01 =  New-AzSnapshotConfig -SourceUri $DataDisk_01_ID -Location $location -CreateOption copy

#config of Data02 snapshot
$DataDisk_02_ID = (Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $Data_02).Id
$config_snapshot_Data02 =  New-AzSnapshotConfig -SourceUri $DataDisk_02_ID -Location $location -CreateOption copy

#creation of OS snapshot
New-AzSnapshot -Snapshot $config_snapshot_OS -SnapshotName $Os_Drive_snap -ResourceGroupName $newresourceGroupName

#creation of Data01 snapshot
New-AzSnapshot -Snapshot $config_snapshot_Data01 -SnapshotName $Data_01_snap -ResourceGroupName $newresourceGroupName

#creation of Data02 snapshot
New-AzSnapshot -Snapshot $config_snapshot_Data02 -SnapshotName $Data_02_snap -ResourceGroupName $newresourceGroupName

# creation of OS Drive from snapshot
$Os_DiskSize = (Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $Os_Drive).DiskSizeGB   
$OS_snapshot = Get-AzSnapshot -ResourceGroupName $newresourceGroupName -SnapshotName $Os_Drive_snap
$diskConfig_OS = New-AzDiskConfig -DiskSizeGB $Os_DiskSize -SkuName $storageType -Location $location -CreateOption Copy -SourceResourceId $OS_snapshot.Id
$OsDisk = New-AzDisk -Disk $diskConfig_OS -ResourceGroupName $newresourceGroupName -DiskName $Os_Drive_new

# creation Data01 Drive from snapshot
$Data01_DiskSize = (Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $Data_01).DiskSizeGB   
$Data01_snapshot = Get-AzSnapshot -ResourceGroupName $newresourceGroupName -SnapshotName $Data_01_snap
$diskConfig_Data01 = New-AzDiskConfig -DiskSizeGB $Data01_DiskSize -SkuName $storageType -Location $location -CreateOption Copy -SourceResourceId $Data01_snapshot.Id
$Data01_Disk = New-AzDisk -Disk $diskConfig_Data01 -ResourceGroupName $newresourceGroupName -DiskName $Data_01_new


# creation Data02 Drive from snapshot
$Data02_DiskSize = (Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $Data_02).DiskSizeGB   
$Data02_snapshot = Get-AzSnapshot -ResourceGroupName $newresourceGroupName -SnapshotName $Data_02_snap
$diskConfig_Data02 = New-AzDiskConfig -DiskSizeGB $Data02_DiskSize -SkuName $storageType -Location $location -CreateOption Copy -SourceResourceId $Data02_snapshot.Id
$Data02_Disk = New-AzDisk -Disk $diskConfig_Data02 -ResourceGroupName $newresourceGroupName -DiskName $Data_02_new


################ VM Deployment ################

#-------------VM config----------------#

# vnet and snet for nic
$vNet = Get-AzVirtualNetwork -Name $vNet_name
$sNet = ((Get-AzVirtualNetwork -Name $vNet_name).Subnets | Where-Object name -Like $sNet_name).id

#NIC for clone VM + Accelerated networking
$nicName = "nic-$originalVM"
$nic = New-AzNetworkInterface -Location $location -Name $nicName -ResourceGroupName $newresourceGroupName -SubnetId $sNet -PrivateIpAddress $IP

# if accelerated networking required - please note some of the VM SKU do not support this feature
#$nic.EnableAcceleratedNetworking = $true
#$nic | Set-AzNetworkInterface

# Set config for the VM name and the size
$vmConfig = New-AzVMConfig -VMName $newVM -VMSize $vmSize

# Add the NIC to the new VM
$VM = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Add the OS disk to the new VM
$VM = Set-AzVMOSDisk -VM $VM -ManagedDiskId $OsDisk.Id -StorageAccountType Standard_LRS -CreateOption Attach -Windows

# Add the Data 01 to the  new VM
$VM = Add-AzVMDataDisk -VM $VM -name $Data01_Disk.name -ManagedDiskId $Data01_Disk.id  -StorageAccountType Standard_LRS -CreateOption Attach -Lun 0 -Caching None

# Add the Data 02 to the  new VM
$VM = Add-AzVMDataDisk -VM $VM -name $Data02_Disk.name -ManagedDiskId $Data02_Disk.id  -StorageAccountType Standard_LRS -CreateOption Attach -Lun 1 -Caching None

# boot diag for the VM
$diag_storage_account_name = (Get-AzStorageAccount -ResourceGroupName $storage_account_rg -Name $storage_account).StorageAccountName
$VM = Set-AzVMBootDiagnostic -VM $VM -Enable -ResourceGroupName $storage_account_rg -StorageAccountName $diag_storage_account_name

# Deployment of the VM
New-AzVM -ResourceGroupName $newresourceGroupName -Location $location -VM $VM -LicenseType "Windows_Server"

# set up Azure VM backup
$vault = Get-AzRecoveryServicesVault -Name $backup_vault 
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name $policy_name -VaultId $vault.ID
Enable-AzRecoveryServicesBackupProtection -Policy $policy -Name $newVM -ResourceGroupName $newresourceGroupName -VaultId $vault.ID


# diag extention for the VM
$DeployedVM = Get-AzVM -ResourceGroupName $newresourceGroupName -VMName $newVM
(Get-Content ((Get-Location).Path + "\template.json")) -replace ’<VMName>’, $DeployedVM.Id | Out-File ("template-" + $DeployedVM.Name + ".json") -Force

Set-AzVMDiagnosticsExtension -ResourceGroupName $newresourceGroupName -VMName $newVM -DiagnosticsConfigurationPath ("template-" + $DeployedVM.Name + ".json") -StorageAccountName $diag_storage_account_name

################ Junk removal ################

# delition of OS snapshot
Remove-AzSnapshot -ResourceGroupName $newresourceGroupName -SnapshotName $Os_Drive_snap -Force

# delition of Data01 snapshot
Remove-AzSnapshot -ResourceGroupName $newresourceGroupName -SnapshotName $Data_01_snap -Force

# delition of Data02 snapshot
Remove-AzSnapshot -ResourceGroupName $newresourceGroupName -SnapshotName $Data_02_snap -Force

# stop timer 
$watch.Stop() 
Write-Host $watch.Elapsed