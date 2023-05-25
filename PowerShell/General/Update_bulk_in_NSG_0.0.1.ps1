#########################################
# Az module required
# The script updates NSG with new rules as per provided csv file 
#########################################

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"
# Replace < ... > with rg name
$rgName = "< ... >"
# Replace < ... > with nsg name
$nsgName = "< ... >"
# Replace < ... > with csv file name and full path
$file = "< ... >"

$NSG = Get-AzNetworkSecurityGroup -ResourceGroupName $rgName -Name $nsgName


foreach ($rule in import-csv $file -Delimiter ";")
{
   $NSG | Add-AzNetworkSecurityRuleConfig `
    -name $rule.name 
    -Direction Inbound `
    -Access Allow `
    -SourceAddressPrefix $rule.sourse `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange $rule.port `
    -Protocol Tcp -Priority $rule.priority
}

$NSG | Set-AzNetworkSecurityGroup