#########################################
# The script is for mannual trigger from local machine
# The script allows to add a user to Azure DevOps with particular license ( Basic or Stakeholder ) 
# and grant membership in Project Collection Administrators group for more then 1 DevOps organization (depends on PAT)
#
# For Basic license apply the following 
# "accountLicenseType": 2,
# "licenseDisplayName": "$accessLevel" , where $accessLevel must be declared below as Basic 
#
# Required:
# Azure PAT token - to be configureated at Azure DevOps size
# PAT_READWRITE (Graph - READ & MANAGE ; Member Entitlement Management - READ & WRITE ; User Profile - READ & WRITE  )
#########################################

# Replace < ... > with email, license, origin ID, organization name; 
# Stakeholder license is default; Basic is optional;
# Project Collection Administrators group is default;
$userEmail = "< ... >"
$originId = "< ... >"
$accessLevel = "Stakeholder"
$orgName = "< ... >"
$groupName = "Project Collection Administrators"
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

# JSON for Group's API body
$jsonBodyGroup = @"
{
    "storageKey":"",
    "principalName":"$userEmail",
    "origin":"aad"
}
"@

# Setting up variable authentication to Azure DevOps
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

# Get a list of organizations for the authenticated user
$orgNamesUrl = "https://vssps.dev.azure.com/_apis/accounts?memberId=$($env:SYSTEM_ACCESSTOKEN)"
$orgNames = Invoke-RestMethod -Uri $orgNamesUrl -Headers $headers -Method Get

# Output the list of organizations
foreach ($orgName in $orgNames) {

Write-Output "Working on $($orgName.AccountName)"

#####
# Adding user and granting license for user
#####

# remove doNotSendInviteForNewUsers=true& if notification required
$url = "https://vsaex.dev.azure.com/$($orgName.AccountName)/_apis/userentitlements?doNotSendInviteForNewUsers=true&api-version=7.1-preview.3"
# Authenticating Azure DevOps and Sending DevOps API PATCH method with JSON body
Invoke-RestMethod -Uri $url -Method PATCH -Headers $headers -ContentType "application/json-patch+json" -Body $jsonBodyUser

#####
# Adding to the group
#####
# Set variable for API Group Description
$urlGroupDescriptor = "https://vssps.dev.azure.com/$($orgName)/_apis/graph/groups?&api-version=7.2-preview.1"
# Get group descriptors from the DevOps organization
$resultGroupDescriptor = Invoke-RestMethod -Uri $urlGroupDescriptor -Method GET -Headers $headers
# Set Project Collection Administrators group descriptor as a variable
$descriptor = ($resultGroupDescriptor.value | Where-Object displayName -EQ $groupName).descriptor
# Set variable for API with the group descriptor
$urlGroupAccess = "https://vssps.dev.azure.com/$($orgName)/_apis/graph/Users?groupDescriptors=$($descriptor)&api-version=7.2-preview.1"
# Authenticating Azure DevOps and Sending DevOps API POST method with JSON body
Invoke-RestMethod -Uri $urlGroupAccess -Method POST -Headers $headers -ContentType "application/json" -Body $jsonBodyGroup
}