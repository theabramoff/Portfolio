#########################################
# The script is for mannual trigger from local machine
# The script allows to dump idle Azure DevOps lincesed from Basic and Basic + Test Plan for everyone who has not access an organization for 2 months. It works within all organization where a PAT token has access
# As the result it returns csv file
# Required:
# Azure PAT token - to be configureated at Azure DevOps size
# PAT_READONLY (Graph - READ ; Member Entitlement Management - READ ; User Profile - READ  )
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$file="< ... >\DevOps_Audit_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 

$vmobjs = @()

# Authenticate to Azure DevOps
# Replace < ... > with PAT token (it's better to pass the value from env. variable)
$PAT = "< ... >" #PAT_READONLY (Graph - READ ; Member Entitlement Management - READ ; User Profile - READ  )

# Get a list of organizations for the authenticated user
$orgsUrl = "https://vssps.dev.azure.com/_apis/accounts?memberId=$($env:SYSTEM_ACCESSTOKEN)"
$orgs = Invoke-RestMethod -Uri $orgsUrl -Headers @{
    Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$($PAT)")))"
} -Method Get

# Output the list of organizations
$organizations = $orgs.AccountName

# Output the list of organizations
foreach ($organization in $organizations) {

    Write-Output "Working on $organization"

    # Get a list of all users in the organization
    $userListUrl = "https://vssps.dev.azure.com/$organization/_apis/graph/users?api-version=7.0-preview.1"
    $userListResponse = Invoke-RestMethod -Uri $userListUrl -Headers @{
    Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$($PAT)")))"
    } -Method Get
    $userList = $userListResponse.value | Where-Object origin -eq "aad"

        # Iterate through the list of users
        foreach ($user in $userList) {
            $userDescriptor = $user.descriptor

            $userUrl = "https://vsaex.dev.azure.com/$organization/_apis/userentitlements/${userDescriptor}?api-version=7.0"
            $userResponse = Invoke-RestMethod -Uri $userUrl -Headers @{
            Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$($PAT)")))"
            } -Method Get
            $userLicense = $userResponse.accessLevel.licenseDisplayName
                
            # Check if the user has a Basic license and hasn't used it in the last 2 months
            $lastAccessTime = [DateTime]::Parse($userResponse.lastAccessedDate)
            $twoMonthsAgo = [DateTime]::UtcNow.AddMonths(-2)

                if (($userResponse.accessLevel.licenseDisplayName -eq "Basic" -or $userResponse.accessLevel.licenseDisplayName -eq "Basic + Test Plans") -and ($twoMonthsAgo -ge $lastAccessTime)) {
                    Write-Output "$($user.displayName) has not used their Basic license in the last 2 months"
                        $vmInfo = [pscustomobject]@{
                        'Organization' = $organization
                        'displayName'= $user.displayName
                        'email' = $user.mailAddress
                        'License'= $userLicense
                        'lastAccessTime'= $lastAccessTime   
                        }
                $vmobjs += $vmInfo
                $vmobjs | Export-Csv -NoTypeInformation -Path $file
                Write-Host "$($user.displayName) written to $file"
                }

        }
}