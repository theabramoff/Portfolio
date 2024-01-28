#########################################
# Az module required
# The script operates with Azure Key Vault secrets from a VM
# Authentication should be done using managed identity assighned to the VM
#########################################

# Replace < ... > with the names
$userName = "< ... >"
$vaultName = "< ... >"
$vaultSecretName = "< ... >"

Write-Host "Logging in with Managed Identity"
Connect-AzAccount -Identity | Out-Null

# Retrieve password from Key Vault
$userPassword =  Get-AzKeyVaultSecret -VaultName $vaultName -name $vaultSecretName -AsPlainText

Write-Host "Retrieved password: ${userPassword}"

# Run commands using the credentials
Write-Host "Running command: Invoke-Command REMOTECOMPUTER command ... -User ${userName} -Pass ${userPassword}"
Read-Host -Prompt "Press any key to continue" 