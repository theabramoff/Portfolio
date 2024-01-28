#########################################
# The script is Runbook for Azure Automation Account
# The script allows to change idle Azure DevOps lincesed from Basic and Basic + Test Plan to Stakeholder for everyone within 1 organization who has not access it for 3 months
#
# Required:
# Azure KeyVault
# Azure Automation account
# Azure PAT token - to be configureated at Azure DevOps size
# PAT_READWRITE (Graph - READ & MANAGE ; Member Entitlement Management - READ & MANAGE ; User Profile - READ & MANAGE  )
#########################################

# Authenticate to Azure
# Replace < ... > to ID ofautomation account managed identity
$splat = @{
    Identity = $true
    AccountId = "< ... >"
}
# Replace < ... > to AKV name
$kv = "< ... >"
$kvSecretName = "PAT-READWRITE"
Connect-AzAccount @splat
# Retrieve Secret from the Azure Key Vault
# - In the Key vault follwling access has to be granted for the Automation Account:
# --- Key permissions 
# ---- GET & LIST
# --- Secret permissions
# ---- GET & LIST
$PAT = Get-AzKeyVaultSecret -VaultName $kv -Name $kvSecretName -AsPlainText

# output (below are)
$Output = [System.Collections.ArrayList]@()

# Replace < ... > to DevOps organization name
$orgName = "< ... >"

# Setting up variable authentication to Azure DevOps

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

$UserParameters = @{
    Method  = "GET"
    Headers = $Headers
    Uri     = "https://vsaex.dev.azure.com/$($orgName)/_apis/userentitlements?api-version=5.1-preview.2"
}
$Users = (Invoke-RestMethod @UserParameters).members

# Iterate through the list of users
foreach ($user in $Users) {

    #$userDescriptor = $user.descriptor

    $userUrl = "https://vsaex.dev.azure.com/$($orgName)/_apis/userentitlements/$($User.id)?api-version=5.1-preview.2"
    $userResponse = Invoke-RestMethod -Uri $userUrl -Method Get -Headers $headers
                
    # Check if the user has a Basic license and hasn't used it in the last 3 months
    $lastAccessTime = [DateTime]::Parse($userResponse.lastAccessedDate)
    $twoMonthsAgo = [DateTime]::UtcNow.AddMonths(-3)
    if (($userResponse.accessLevel.licenseDisplayName -eq "Basic" -or $userResponse.accessLevel.licenseDisplayName -eq "Basic + Test Plans") -and ($twoMonthsAgo -ge $lastAccessTime)) {

        # Construct the patch document to update the license
        $patchDoc = @()
        $patchDoc += @{
            op    = "replace"
            path  = "/accessLevel"
            value = @{
                licensingSource    = "account"
                accountLicenseType = "Stakeholder"
            }
        }
        # Update the user's license to Stakeholder
        $rest = (Invoke-RestMethod -Uri $userUrl -Method PATCH -Headers $headers -ContentType "application/json-patch+json" -Body (ConvertTo-Json -InputObject $patchDoc)).isSuccess

        $User | ForEach-Object {
        $UserObject = [PSCustomObject]@{
            Organization = $orgName
            UserName = $_.user.principalName
            License  = $_.accessLevel.licenseDisplayName
            Updated   = $rest
            #LastAccess = $lastAccessTime
        }
        [void]$Output.Add($UserObject)
        }
    }
}
#Return the output
$Output