#########################################
# Az module required
# The script deploys a Linux VM in an existing vnet
# In case of different VM deployment - these may help:
# - Get-AzVMImagePublisher
# -- Get-AzVMImagePublisher -Location "westeurope" | Where-Object PublisherName -Like "Canonical"
# - Get-AzVMImageOffer
# -- Get-AzVMImageOffer -Location "westeurope" -PublisherName "Canonical"
# - Get-AzVMImageSku 
# -- Get-AzVMImageSku -Location "westeurope" -Offer "UbuntuServer" -PublisherName "Canonical"
# --- Get-AzVMImage -Location "westeurope" -PublisherName "Canonical" -Offer "UbuntuServer" -Sku "18.04-LTS" | Select Version
#########################################

#Replace < ... > with prefix for resources, e.g. az-01-abramov-test
$prefix = "< ... >"
#Replace < ... > with region, e.g. northeurope
$location = "< ... >" 
#Replace < ... > with vm name, e.g. az-vm-01
$vmName = "< ... >"
#Replace < ... > with vm size, e.g. Standard_B2ms
$vmSize = "< ... >"
#Replace < ... > with existing vnet name
$vnetName = "< ... >"

$tags = @{
    OwnedBy             =   "Abramov, Andrey";
    OwnerBackupPerson   =   "N/A";
    ITOwnerGroup        =   "N/A";
    Description         =   "Test Project";
    LifecycleEnd        =   "31DEC2023";
}

Connect-AzAccount
#Replace < ... > with subscription name
Select-AzSubscription "< ... >"

$rg = New-AzResourceGroup -Name "rg-$prefix" -Location $location -Tag $tags

#####
# Networking
#####
$vnet = Get-AzVirtualNetwork -Name $vnetName
$NIC = New-AzNetworkInterface -Name "nic-$vmName" -ResourceGroupName $rg.ResourceGroupName -Location $rg.location -SubnetId $vnet.Subnets[0].id

#####
# Virtual Machine
#####
$VM = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$VM = Set-AzVMOperatingSystem -VM $VM -Linux -ComputerName $vmName -Credential (Get-Credential -UserName "sysmgr" -Message "Provide password")
$VM = Add-AzVMNetworkInterface -VM $VM -Id $NIC.Id
$VM = Set-AzVMOSDisk -VM $VM -Name "vhd-$vmName-os" -StorageAccountType "Standard_LRS" -CreateOption "FromImage" -Linux 
$VM = Set-AzVMSourceImage -VM $VM -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version latest

New-AzVM -ResourceGroupName $rg.ResourceGroupName -Location $rg.location -VM $VM | Out-Null