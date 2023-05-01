#########################################
# Az module required
# The script enables Accelerated Networking feature
#########################################

# Replace < ... > with reaource group name
$RG = "< ... >"
# Replace < ... > with VM's nic name
$NicName = "< ... >"

Connect-AzAccount
# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

$nic = Get-AzNetworkInterface -ResourceGroupName $RG -Name $NicName

$nic.EnableAcceleratedNetworking = $true

$nic | Set-AzNetworkInterface