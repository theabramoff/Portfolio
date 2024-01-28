#########################################
# The script is for mannual trigger from local machine
# The script allows to change idle Azure DevOps lincesed from Basic and Basic + Test Plan to Stakeholder for everyone within 1 organization who has not access it for 3 months
#
# Required:
# Azure KeyVault
# Azure PAT token - to be configureated at Azure DevOps size
# PAT_READWRITE (Graph - READ & MANAGE ; Member Entitlement Management - READ & MANAGE ; User Profile - READ & WRITE  )
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$file="< ... >\DevOps_Licence_Switch_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 

# output (below are)
$Output = [System.Collections.ArrayList]@()

# Replace < ... > to DevOps organization name
$orgName = "< ... >"

# Setting up variable authentication to Azure DevOps
# Replace < ... > with PAT token (it's better to pass the value from env. variable)
$PAT = "< ... >"  
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
# Export the output array to CSV
$output | Export-Csv -Path $file -NoTypeInformation