# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# Replace < ... > with the rg name
$rgName = "< ... >"
# Replace < ... > with the vault name
$vault = "< ... >"
# Replace < ... > with the server name
$server = "< ... >"

$targetVault = Get-AzRecoveryServicesVault -ResourceGroupName $rgName -Name $vault
Set-AzRecoveryServicesVaultContext -Vault $targetVault

$container = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVMAppContainer " -Status "Registered" -FriendlyName $server -VaultId $targetVault.ID
Unregister-AzRecoveryServicesBackupContainer -Container $container