#########################################
# Az module required
# The script is for simle vnet, snet and rt deployment 
#########################################

# Replace < ... > with resource group name, e.g. rg-***
$rgName = "< ... >"
# Replace < ... > with region name, e.g. northeurope
$location = "< ... >"
# Replace < ... > with virtual network name, e.g. vnet-***
$vnetName = "< ... >"
# Replace < ... > with virtual network address prefix, e.g. 10.0.0.0/16
$vnetAddress = "< ... >"
# Replace < ... > with subnet name, e.g. snet-***
$snetName = "< ... >"
# Replace < ... > with subnet address prefix, e.g. 10.0.0.0/16
$snetAddress = "< ... >"
# Replace < ... > with route table name, e.g. rt-***
$rtName = "< ... >"

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# rg deployment
New-AzResourceGroup -Name $rgName -Location $location

# rt deployment
New-AzRouteTable -Name $rtName -ResourceGroupName $rgName -location $location -DisableBgpRoutePropagation
# rt default route , replace < ... > with address prefix (e.g 0.0.0.0/0) and next hop IP (e.g. 10.72.55.132), next hop by default is an applience
Get-AzRouteTable -ResourceGroupName $rgName -Name $rtName | Add-AzRouteConfig -Name "default-route" -AddressPrefix "< ... >" -NextHopType "VirtualAppliance" -NextHopIpAddress "< ... >" | Set-AzRouteTable

# vnet / snet deployment
$subnet = New-AzVirtualNetworkSubnetConfig -Name $snetName -AddressPrefix $vnetAddress
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $snetAddress -Subnet $subnet

