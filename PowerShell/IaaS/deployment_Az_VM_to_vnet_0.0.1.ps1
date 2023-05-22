#########################################
# Az module required
# The script deploys a Windows VM in a vnet
# In case of different VM deployment - these may help:
# - Get-AzVMImagePublisher
# - Get-AzVMImageOffer
# - Get-AzVMImageSku 
#########################################

#Replace < ... > with region, e.g. northeurope
$location = "< ... >" 
#Replace < ... > with vm name, e.g. az-vm-01
$vmName = "< ... >"
#Replace < ... > with vm size, e.g. Standard_B2ms
$vmSize = "< ... >"
#Replace < ... > with existing vnet name
$vnetName = "< ... >"

Connect-AzAccount
#Replace < ... > with subscription name
Select-AzSubscription "< ... >"

$rg = New-AzResourceGroup -Name "rgrp-$vmName" -Location $location

$vnet = Get-AzVirtualNetwork -Name $vnetName
$NIC = New-AzNetworkInterface -Name "nic-$vmName" -ResourceGroupName $rg.ResourceGroupName -Location $rg.location -SubnetId $vnet.Subnets[0].id

# remove license type in case non-windows deployment
$VM = New-AzVMConfig -VMName $vmName -VMSize $vmSize -LicenseType "Windows_Server"
$VM = Set-AzVMOperatingSystem -VM $VM -Windows -ComputerName $vmName -Credential (Get-Credential) -ProvisionVMAgent
$VM = Add-AzVMNetworkInterface -VM $VM -Id $NIC.Id
$VM = Set-AzVMOSDisk -VM $VM -Name "vhd-$vmName-os" -StorageAccountType "Standard_LRS" -CreateOption "FromImage" -Windows
$VM = Set-AzVMSourceImage -VM $VM -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version latest

New-AzVM -ResourceGroupName $rg.ResourceGroupName -Location $rg.location -VM $VM | Out-Null