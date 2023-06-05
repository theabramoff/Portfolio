#########################################
# Az module required
# The script operates with Azure Key Vault secrets from a VM
# Authentication should be done using managed identity assighned to the VM
#########################################


# replace < ... > with the key vault name
$vault = "< ... >"
# Setting secret from console 
$secret = Read-Host -AsSecureString

Write-Host "Logging in with Managed Identity"
Connect-AzAccount -Identity | Out-Null

# Set secret from azure key vault for e.g. admin 
Set-AzKeyVaultSecret -VaultName $vault -name "admin" -SecretValue $secret
# Get secret from azure key vault for e.g. admin  
Get-AzKeyVaultSecret -VaultName $vault -name "admin" -AsPlainText
