#########################################
# The script is for mannual trigger from local machine
# The script allows to grant membership in Project Collection Administrators group for a particular DevOps organization
#
# Required:
# Azure PAT token - to be configureated at Azure DevOps size
# PAT_READWRITE (Graph - READ & MANAGE ; Member Entitlement Management - READ & WRITE ; User Profile - READ & WRITE  )
#########################################

# Replace < ... > with email and organization name; 
# Project Collection Administrators group is default;
$userEmail = "< ... >"
$orgName = "< ... >"
$groupName = "Project Collection Administrators"
# Replace < ... > with PAT token (it's better to pass the value from env. variable)
$PAT = "< ... >" 

# DevOps Group API's body JSON
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
