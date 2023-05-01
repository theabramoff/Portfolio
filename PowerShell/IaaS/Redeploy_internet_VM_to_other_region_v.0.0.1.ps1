#########################################
# Az module required
# this script deployes a VM from existing internet facing VM VHDs to new RGs using snapshots
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$file="< ... >\VM_deployment" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
)

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# Replace < ... > with rg
$rg = "< ... >"
# Replace < ... > with vm
$vmName = "< ... >"
# Replace < ... > with new rg
$newRg= "< ... >"
# Replace < ... > with new nsg
$newNSG = "< ... >"
# Replace < ... > with PIP for RDP whitelisting
$whitelistedIP = "< ... >"
# Replace < ... > with new vnet
$newVnet = "< ... >"
# Replace < ... > with new snet
$newSnet = "< ... >"
# Replace < ... > with new vnet range
$vnetRange = "< ... >"
# Replace < ... > with new location
$newLocation = "< ... >"
# Replace < ... > with new sa
$newStorageAccountName = "< ... >"

$originalVM = get-azurermvm -ResourceGroupName $rg -Name $vmName

("VM Name: " + $originalVM.Name) | Out-File -FilePath $file 
("Extensions: " + $originalVM.Extensions) | Out-File -FilePath $file -Append
("VMSize: " + $originalVM.HardwareProfile.VmSize) | Out-File -FilePath $file -Append
("NIC: " + $originalVM.NetworkProfile.NetworkInterfaces[0].Id) | Out-File -FilePath $file -Append
("OS Type: " + $originalVM.StorageProfile.OsDisk.OsType) | Out-File -FilePath $file -Append
("OS Disk: " + $originalVM.StorageProfile.OsDisk.ManagedDisk.id) | Out-File -FilePath $file -Append
if ($originalVM.StorageProfile.DataDisks) { 
    ("Data Disk(s): ") | Out-File -FilePath $file -Append 
    foreach ($disk in $originalVM.StorageProfile.DataDisks ) {     
        ("   " + $disk.Name + "  " + $disk.ManagedDisk.Id) | Out-File -FilePath $file -Append 
    }   
}

$newStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $newRG -Name $newStorageAccountName
$storKey=Get-AzureRmStorageAccountKey -ResourceGroupName $newRG -Name $newStorageAccountName
$storageContext = New-AzureStorageContext -StorageAccountName $newStorageAccountName -StorageAccountKey $storKey[0].Value
New-AzureStorageContainer -Context $storageContext -Name vhds

# OS Disk
$strNewOSdiskName = 'vhd-'+$vmName+'-os.vhd'
$sasOS = Grant-AzureRmDiskAccess -ResourceGroupName $rg -DiskName $originalVM.StorageProfile.OsDisk.name -DurationInSecond 36000 -Access Read
Start-AzureStorageBlobCopy -AbsoluteUri $sasOS.AccessSAS -DestContext $storageContext -DestBlob $strNewOSdiskName -DestContainer vhds

# Data Disk
if ($originalVM.StorageProfile.DataDisks) { 
    $i=0
    foreach ($disk in $originalVM.StorageProfile.DataDisks ) {
        $i++    
        $strNewDatadiskName = 'vhd-'+$vmName+'_data0'+$i+'.vhd'
        $sasData = Grant-AzureRmDiskAccess -ResourceGroupName $rg -DiskName $disk.name -DurationInSecond 36000 -Access Read
        Start-AzureStorageBlobCopy -AbsoluteUri $sasData.AccessSAS -DestContext $storageContext -DestBlob $strNewDatadiskName -DestContainer vhds
    }   
}

# wait till copy completed
while ($true) {
    $status = Get-AzureStorageBlobCopyState $strNewOSdiskName -Context $storageContext -Container vhds
    $stringOut = [string]$status.status + ' ' + ($status.bytescopied/$status.totalbytes).ToString("P") + ' ' + $originalVM.StorageProfile.OsDisk.name
    if ($originalVM.StorageProfile.DataDisks) { 
        $i=0
        foreach ($disk in $originalVM.StorageProfile.DataDisks ) {     
            $i++
            $strNewDatadiskName = 'vhd-'+$vmName+'_data0'+$i+'.vhd'
            $status = Get-AzureStorageBlobCopyState $strNewDatadiskName -Context $storageContext -Container vhds
            $stringOut = $stringOut + ' ' + $status.status + ' ' + ($status.bytescopied/$status.totalbytes).ToString("P") + ' ' + $disk.name
        }
    }
    write-host $stringOut
    sleep 30
}

# create vm from VHD

$newVM = New-AzureRmVMConfig -VMName $originalVM.Name -VMSize $originalVM.HardwareProfile.VmSize
$osDiskName = $strNewOSdiskName.Replace('.vhd','')
$osDiskUri = $storageContext.StorageAccount.BlobEndpoint.AbsoluteUri +'vhds/'+$strNewOSdiskName
Set-AzureRmVMOSDisk -VM $NewVM -VhdUri $osDiskUri -Name $osDiskName -CreateOption Attach -Windows

if ($originalVM.StorageProfile.DataDisks) { 
    $i=0
    foreach ($disk in $originalVM.StorageProfile.DataDisks ) {     
        $i++
        $dataDiskName = 'vhd-'+$vmName+'-data0'+$i
        $dataDiskUri = $storageContext.StorageAccount.BlobEndpoint.AbsoluteUri +'vhds/'+$dataDiskName+'.vhd'
        Add-AzureRmVMDataDisk -VM $newVM -Name $dataDiskName -VhdUri $dataDiskUri -Caching $disk.Caching -Lun $disk.Lun -CreateOption Attach -DiskSizeInGB $disk.DiskSizeGB
    }
}

$newPIP=New-AzureRmPublicIpAddress -Name ('pip-'+$vmName) -ResourceGroupName $newRG -Location $newLocation -AllocationMethod Dynamic
$newNSGObj = New-AzureRmNetworkSecurityGroup -Name $newNSG -ResourceGroupName $newRg -Location $newLocation

$newVnetObj=New-AzureRmVirtualNetwork -Name $newVnet -ResourceGroupName $newRG -Location $newLocation -AddressPrefix $vnetRange

Add-AzureRmVirtualNetworkSubnetConfig -Name $newSnet -VirtualNetwork $newVnetObj -AddressPrefix $vnetRange -NetworkSecurityGroupId $newNSGObj.Id
$newVnetObj | Set-AzureRmVirtualNetwork

$newVnetObj = Get-AzureRmVirtualNetwork -Name $newVnet -ResourceGroupName $newRG
$newSnetObj = Get-AzureRmVirtualNetworkSubnetConfig -Name $newSnet -VirtualNetwork $newVnetObj

$newNIC=New-AzureRmNetworkInterface -Name ('nic-'+$vmName) -ResourceGroupName $newRg -Location $newLocation -SubnetId $newSnetObj.Id -PublicIpAddressID $newPIP.Id -NetworkSecurityGroupId (Get-AzureRmNetworkSecurityGroup -Name $newNSG -ResourceGroupName $newRg).Id

Add-AzureRmVMNetworkInterface -VM $NewVM -Id $newNIC.Id

New-AzureRmVM -ResourceGroupName $newRG -Location $newLocation -VM $NewVM -DisableBginfoExtension

$newNSGObj = Get-AzureRmNetworkSecurityGroup -Name $newNSG -ResourceGroupName $newRg
Add-AzureRmNetworkSecurityRuleConfig -Name Allow_RDP -NetworkSecurityGroup $newNSGObj -Protocol TCP -SourcePortRange * -SourceAddressPrefix $whitelistedIP -Access Allow -Direction Inbound -DestinationPortRange 3389 -DestinationAddressPrefix * -Priority 120
$newNSGObj | Set-AzureRmNetworkSecurityGroup
