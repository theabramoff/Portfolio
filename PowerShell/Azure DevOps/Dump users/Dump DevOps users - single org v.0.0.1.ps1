#########################################
# The script is for mannual trigger from local machine
# The script allows to dump idle Azure DevOps lincesed from Basic and Basic + Test Plan for everyone who has not access an organization for 3 months. 
# It works within single organization where a PAT token has access
#
# Required:
# Azure PAT token - to be configureated at Azure DevOps size
# PAT_READONLY (Graph - READ ; Member Entitlement Management - READ ; User Profile - READ  )
#########################################

# Replace < ... > to DevOps organization name
$orgName = "< ... >"

# Setting up variable authentication to Azure DevOps
# Replace < ... > with PAT token (it's better to pass the value from env. variable)
$PAT = "< ... >" 
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
}

# Get a list of all users in the organization
$userListUrl = "https://vssps.dev.azure.com/$($orgName)/_apis/graph/users?api-version=7.0-preview.1"
$userListResponse = Invoke-RestMethod -Uri $userListUrl -Method Get -Headers $headers
$userList = $userListResponse.value | Where-Object origin -eq "aad"

# Iterate through the list of users
foreach ($user in $userList) {
    $userDescriptor = $user.descriptor

    $userUrl = "https://vsaex.dev.azure.com/$($orgName)/_apis/userentitlements/$($userDescriptor)?api-version=7.0"
    $userResponse = Invoke-RestMethod -Uri $userUrl -Method Get -Headers $headers
                
    # Check if the user has a Basic license and hasn't used it in the last 3 months
    $lastAccessTime = [DateTime]::Parse($userResponse.lastAccessedDate)
    $twoMonthsAgo = [DateTime]::UtcNow.AddMonths(-3)
    if (($userResponse.accessLevel.licenseDisplayName -eq "Basic" -or $userResponse.accessLevel.licenseDisplayName -eq "Basic + Test Plans") -and ($twoMonthsAgo -ge $lastAccessTime)) {
        Write-Output "$($user.displayName) has not used their Basic license in the last 3 months"
    }
}
