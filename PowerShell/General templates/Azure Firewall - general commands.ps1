############################
# Stop an existing firewall
############################
# Replace < ... > with parameters: FW name , RG, vNet, Public IP
$azfwName = "< ... >" 
$azfwRG = "< ... >" 
$azfwVnet = "< ... >" 
$azfwPIP1 = "< ... >" 
# Replace < ... > if Managed Public IP used (FW with force tunneling)
$azfwPIPmgt = "< ... >" 
# Replace < ... >
$azfwPIP2 = "< ... >" 

$azfw = Get-AzFirewall -Name $azfwName -ResourceGroupName $azfwRG
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw

############################
# Start the firewall with force tunneling
############################

$azfw = Get-AzFirewall -Name $azfwName -ResourceGroupName $azfwRG
$vnet = Get-AzVirtualNetwork -ResourceGroupName $azfwRG -Name $azfwVnet
$pip= Get-AzPublicIpAddress -ResourceGroupName $azfwRG -Name $azfwPIP1
$mgmtPip = Get-AzPublicIpAddress -ResourceGroupName $azfwRG -Name $azfwPIPmgt
$azfw.Allocate($vnet, $pip, $mgmtPip)
$azfw | Set-AzFirewall

############################
# Start the firewall without force tunneling with 1 PIP
############################

$azfw = Get-AzFirewall -Name $azfwName -ResourceGroupName $azfwRG
$vnet = Get-AzVirtualNetwork -ResourceGroupName $azfwRG -Name $azfwVnet
$pip = Get-AzPublicIpAddress -ResourceGroupName $azfwRG -Name $azfwPIP1
$azfw.Allocate($vnet,@($pip))
Set-AzFirewall -AzureFirewall $azfw


############################
# Start the firewall without force tunneling with several PIPs
############################

$azfw = Get-AzFirewall -Name $azfwName -ResourceGroupName $azfwRG
$vnet = Get-AzVirtualNetwork -ResourceGroupName $azfwRG -Name $azfwVnet
$pip1 = Get-AzPublicIpAddress -ResourceGroupName $azfwRG -Name $azfwPIP1
$pip2 = Get-AzPublicIpAddress -ResourceGroupName $azfwRG -Name $azfwPIP2
$azfw.Allocate($vnet,@($pip1,$pip2))
Set-AzFirewall -AzureFirewall $azfw