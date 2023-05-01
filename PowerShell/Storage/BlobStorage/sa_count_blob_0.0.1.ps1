#########################################
# Az module required
# this script shows how to get the total size of the blobs in a container in single subscription
# note: this retrieves all of the blobs in the container in one command. 
# if you are going to run this against a container with a lot of blobs (more than a couple hundred), use continuation tokens to retrieve the list of blobs.
#########################################

# function description for write logs 
Function Write-HostAndLog  
{
 param ($FuncWHLText,$FuncWHLOutFile)
 Write-Host $FuncWHLText
 Add-Content $FuncWHLOutFile $FuncWHLText
}

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with subscription name
Select-AzSubscription "< ... >"

# these are for the storage account to be used
# Replace < ... > with rg name
$resourceGroup = "< ... >"
# Replace < ... > with sa name
$storageAccountName = "< ... >"
# Replace < ... > with container name
$containerName = "< ... >"

# get a reference to the storage account and the context
$storageAccount = Get-AzStorageAccount `
  -ResourceGroupName $resourceGroup `
  -Name $storageAccountName
$ctx = $storageAccount.Context 

# get a list of all of the blobs in the container 
$listOfBLobs = Get-AzStorageBlob -Container $ContainerName -Context $ctx 

# zero out our total
$length = 0

# this loops through the list of blobs and retrieves the length for each blob
#   and adds it to the total
$listOfBlobs | ForEach-Object {$length = $length + $_.Length}

# output the blobs and their sizes and the total 
#Write-Host "List of Blobs and their size (length)"
#Write-Host " " 
#$listOfBlobs | select Name, Length
Write-Host " "

Write-HostAndLog  "$(Get-Date): Total Length = $length" 