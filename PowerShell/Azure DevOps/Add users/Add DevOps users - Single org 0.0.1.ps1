#########################################
# The script is for mannual trigger from local machine
# The script allows to add a user to Azure DevOps with particular license ( Basic or Stakeholder )
#
# For Basic license apply the following 
# "accountLicenseType": 2,
# "licenseDisplayName": "$accessLevel" , where $accessLevel must be declared below as Basic 
#
# Required:
# Azure PAT token - to be configureated at Azure DevOps size
# PAT_READWRITE (Graph - READ & MANAGE ; Member Entitlement Management - READ & WRITE ; User Profile - READ & WRITE  )
#########################################


# Replace < ... > with email, license and origin ID; 
# Stakeholder license is default; Basic is optional;
$userEmail = "< ... >"
$originId = "< ... >"
$accessLevel = "Stakeholder"
# Replace < ... > with PAT token (it's better to pass the value from env. variable)
$PAT = "< ... >" 

# User API's body JSON
$jsonBodyUser = @"
[
    {
        "from": "",
        "op": 0,
        "path": "",
        "value": {
            "accessLevel": {
                "accountLicenseType": 5,
                "licenseDisplayName": "$accessLevel"
            },
            "user": {
                "principalName": "$userEmail",
                "origin": "aad",
                "originId": "$originId",
                "subjectKind": "user"
            }
        }
    }
]
"@

# Setting up variable authentication to Azure DevOps
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

# remove doNotSendInviteForNewUsers=true& if notification required
$url = "https://vsaex.dev.azure.com/$($orgName)/_apis/userentitlements?doNotSendInviteForNewUsers=true&api-version=7.1-preview.3"

# Authenticating Azure DevOps and Sending DevOps API PATCH method with JSON body
Invoke-RestMethod -Uri $url -Method PATCH -Headers $headers -ContentType "application/json-patch+json" -Body $jsonBodyUser