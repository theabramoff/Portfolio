#########################################
# Az module required
# The script enables Azure Hybrid Benefit for a single Windows Servers
#########################################

# Replace < ... > with reaource group name
$rg = "< ... >"
# Replace < ... > with server name
$server = "< ... >"

Connect-AzAccount
# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

$vm = get-azvm -ResourceGroupName $rg -Name $server
$vm.LicenseType = "Windows_Server"
Update-AzVM -ResourceGroupName $rg -VM $vm