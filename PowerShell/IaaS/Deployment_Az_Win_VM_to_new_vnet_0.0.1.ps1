#########################################
# Az module required
# The script deploys a Windows VM in a new vnet
# In case of different VM deployment - these may help:
# - Get-AzVMImagePublisher
# -- Get-AzVMImagePublisher -Location "westeurope" | Where-Object PublisherName -Like "MicrosoftWindowsServer"
# - Get-AzVMImageOffer
# -- Get-AzVMImageOffer -Location "westeurope" -PublisherName "MicrosoftWindowsServer"
# - Get-AzVMImageSku 
# -- Get-AzVMImageSku -Location "westeurope" -Offer "WindowsServer" -PublisherName "MicrosoftWindowsServer"
# --- Get-AzVMImage -Location "westeurope" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Sku "2019-Datacenter" | Select Version
#########################################

Connect-AzAccount
#Replace < ... > with subscription name
Select-AzSubscription "< ... >"
#Replace < ... > with prefix for resources, e.g. az-01-abramov-test
$prefix = "< ... >" 
#Replace < ... > with region, e.g. westeurope
$location = "< ... >"
#Replace < ... > with server name, azvm-srv-01
$vmName = "< ... >"
#Replace < ... > with server SKU, e.g. Standard_B2ms
$vmSize = "< ... >"
#Replace < ... > with address prefix for vnet and snet, e.g. 10.10.132.0/24
$vnetAddress = "< ... >"

$tags = @{
    OwnedBy             =   "Abramov, Andrey";
    OwnerBackupPerson   =   "N/A";
    ITOwnerGroup        =   "N/A";
    Description         =   "Test Project";
    LifecycleEnd        =   "31DEC2023";
}

$rg = New-AzResourceGroup -Name "rg-$prefix" -Location $location -Tag $tags

#####
# Security
#####
$mgmtAsg = New-AzApplicationSecurityGroup `
  -ResourceGroupName $rg.ResourceGroupName `
  -Name "asg-mgmt-$prefix" `
  -Location $location

# As test - no limitations are included  
$mgmtRule = New-AzNetworkSecurityRuleConfig `
  -Name "Allow-RDP-All" `
  -Access Allow `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 110 `
  -SourceAddressPrefix Internet `
  -SourcePortRange * `
  -DestinationApplicationSecurityGroupId $mgmtAsg.id `
  -DestinationPortRange 3389

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $rg.ResourceGroupName -Name "nsg-$prefix" -Location $location -SecurityRules $mgmtRule

#####
# Networking
#####
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name "snet-$prefix" -AddressPrefix $vnetAddress -NetworkSecurityGroupId $nsg.Id
$vnet= New-AzVirtualNetwork -ResourceGroupName $rg.ResourceGroupName -Name "vnet-$vmName" -Location $location -Subnet $subnetConfig -AddressPrefix $vnetAddress
$PIP = New-AzPublicIpAddress -ResourceGroupName $rg.ResourceGroupName -Name "pip-$vmName" -Location $location -Sku "Standard" -AllocationMethod "Static" -DomainNameLabel $vmName
$NIC = New-AzNetworkInterface -Name "nic-$vmName" -ResourceGroupName $rg.ResourceGroupName -Location $rg.location -SubnetId $vnet.Subnets[0].id -PublicIpAddressId $PIP.Id -ApplicationSecurityGroupId $mgmtAsg.Id


#####
# Virtual Machine
#####
$VM = New-AzVMConfig -VMName $vmName -VMSize $vmSize -LicenseType "Windows_Server"
$VM = Set-AzVMOperatingSystem -VM $VM -Windows -ComputerName $vmName -Credential (Get-Credential -UserName "sysmgr" -Message "Provide password") -ProvisionVMAgent
$VM = Add-AzVMNetworkInterface -VM $VM -Id $NIC.Id
$VM = Set-AzVMOSDisk -VM $VM -Name "vhd-$vmName-os" -StorageAccountType "Standard_LRS" -CreateOption "FromImage" -Windows
$VM = Set-AzVMSourceImage -VM $VM -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version latest

New-AzVM -ResourceGroupName $rg.ResourceGroupName -Location $rg.location -VM $VM | Out-Null
