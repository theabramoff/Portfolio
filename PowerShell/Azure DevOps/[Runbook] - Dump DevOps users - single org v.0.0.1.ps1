#########################################
# The script is Runbook for Azure Automation Account
# The script allows to dump idle Azure DevOps linceses Basic and Basic + Test Plan for everyone who has not access organiztion for 2 months
# Required:
# Azure KeyVault
# Azure Automation account
# Azure PAT token - to be configureated at Azure DevOps size
# PAT_READONLY (Graph - READ ; Member Entitlement Management - READ ; User Profile - READ  )
#########################################

# Authenticate to Azure
# Replace < ... > to ID ofautomation account managed identity
$splat = @{
    Identity = $true
    AccountId = "< ... >"
}

# Replace < ... > to AKV name
$kv = "< ... >"
$kvSecretName = "PAT-READONLY"
Connect-AzAccount @splat
# Retrieve Secret from the Azure Key Vault
# - In the Key vault follwling access has to be granted for the Automation Account:
# --- Key permissions 
# ---- GET & LIST
# --- Secret permissions
# ---- GET & LIST
$PAT = Get-AzKeyVaultSecret -VaultName $kv -Name $kvSecretName -AsPlainText

# Replace < ... > to DevOps organization name
$organizationName = "< ... >"

# Authenticate to Azure DevOps
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

# Get a list of all users in the organization
$userListUrl = "https://vssps.dev.azure.com/$organizationName/_apis/graph/users?api-version=7.0-preview.1"
$userListResponse = Invoke-RestMethod -Uri $userListUrl -Method Get -Headers $headers
$userList = $userListResponse.value | Where-Object origin -eq "aad"

# Iterate through the list of users
foreach ($user in $userList) {
    $userDescriptor = $user.descriptor

    $userUrl = "https://vsaex.dev.azure.com/$organizationName/_apis/userentitlements/${userDescriptor}?api-version=7.0"
    $userResponse = Invoke-RestMethod -Uri $userUrl -Method Get -Headers $headers
                
    # Check if the user has a Basic license and hasn't used it in the last 2 months
    $lastAccessTime = [DateTime]::Parse($userResponse.lastAccessedDate)
    $twoMonthsAgo = [DateTime]::UtcNow.AddMonths(-2)
    if (($userResponse.accessLevel.licenseDisplayName -eq "Basic" -or $userResponse.accessLevel.licenseDisplayName -eq "Basic + Test Plans") -and ($twoMonthsAgo -ge $lastAccessTime)) {
        Write-Output "$($user.displayName) has not used their Basic license in the last 2 months"
    }
}