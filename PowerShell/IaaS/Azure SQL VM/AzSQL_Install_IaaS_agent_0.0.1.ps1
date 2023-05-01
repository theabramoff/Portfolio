#########################################
# Az module required
# The script enables License type for SQL Windows Servers
#########################################

# Replace < ... > with SQL VM name
$vmName = "< ... >"
# Replace < ... > with SQL VM resource group
$rg = "< ... >"
# Replace < ... > with license type
    # Is SQL server is Development edition, then use - PAYG
    # Is SQL server is Standard or Enterprise edition, then use - AHAB
$license = "< ... >"

Connect-AzAccount

Select-AzSubscription "< ... >"

$vm = Get-AzVM -name $vmName -ResourceGroupName $rg
New-AzSqlVM -Name $vm.name -ResourceGroupName $vm.ResourceGroupName -Location $vm.Location -LicenseType $license -SqlManagementType FULL