##################
# Module: Az
# Resource providers should be registered:
# - microsoft.insights
# - microsoft.storage
# - Microsoft.Network
#
# to be improve:
# - policies - smart tiering for prd / New-AzRecoveryServicesBackupProtectionPolicy -Name newTierRecommendedPolicy -WorkloadType AzureVM -BackupManagementType AzureVM -RetentionPolicy $retPol -SchedulePolicy $schPol -VaultId $vault.ID -MoveToArchiveTier $true -TieringMode TierRecommended
# - policies - work on timezone improvement
# - naming via variables
# - add extra rsvs for SQL
##################

# replace < ... > with 
# resource group for diagnostic, replace < ... > with rg name where services for logging will be stored, e.g. rg-az...
$rgDiagnostic = "< ... >"
# variables for diagnistic services, replace < ... > with LAW name, sa name, e.g. la-az..., saaz...
$WorkspaceName = "< ... >"
$saProd = "< ... >"
$saNonProd = "< ... >"

# Networking
# resource group for networking, replace < ... > with rg name where services for networking, e.g. rg-az...
$rgNetwork = "< ... >"
# variables for networking settings, replace < ... > with location, vnet name, snet and etc, e.g. westeurope, vnet-az..., snet-az...
$location = "< ... >"
$vnetName = "< ... >"
$vnetAddress = "< ... >" # e.g. 10.10.132.0/24
$snetName = "< ... >"
$snetAddress = "< ... >" # e.g. 10.10.132.0/24
$dns = "< ... >" # e.g. 10.10.128.132

# variables for rt and routs, replace < ... > with rt name and its routs, e.g.
$rtName = "< ... >"
$route_default = "< ... >"
$route_default_prefix = "< ... >" # e.g. 0.0.0.0/0
$route_default_NextHopType = "< ... >" # e.g. VirtualAppliance
$route_default_NextHopIpAddress  = "< ... >"  # e.g. 10.10.128.132

$route_1 = "< ... >"
$route_1_prefix = "< ... >" # e.g. 10.10.128.128/25
$route_1_NextHopType = "< ... >" # e.g. VirtualAppliance
$route_1_NextHopIpAddress  = "< ... >"  # e.g. 10.10.128.132


# Backup
# resource group for backup vaults, replace < ... > with rg name where services for recovery services vault, e.g. rg-az...
$rgBackupRSV = "< ... >"
# resource group for restore points commection - required for backup policy, replace < ... > with rg name e.g. rg-az...
$rgBackupRP = "< ... >"

# replace < ... > with PRD backup vault name, e.g. rsv-as
$rsvNameProd = "< ... >"
# replace < ... > with Non-PRD backup vault name, e.g. rsv-as
$rsvNameNonProd = "< ... >"

# replace < ... > with PRD backup policy name, e.g. BackupPolicy-< retention format like 14D4W >
$policyProdName = "< ... >"
# replace < ... > with PRD backup policy name, e.g. BackupPolicy-< retention format like 14D4W >
$policyNonProdName = "< ... >"

$vaultDiagnosticsName = "Log Analytics based Monitoring and Reporting solution for Azure Backup"

# in case if no policy applied for propagating tags from subscription - tags might be usefull
$tags = @{
    OwnedBy             =   "Abramov, Andrey";
    OwnerBackupPerson   =   "N/A";
    ITOwnerGroup        =   "N/A";
    Description         =   "Landing Zone for Sub 01";
    LifecycleEnd        =   "31DEC2026";
}


Connect-AzAccount

# replace < ... > with subscription name or ID
Select-AzSubscription "< ... >"


###########
# Diagnostics
###########

# Create the resource group for diagnistic resources if needed
try {
    Get-AzResourceGroup -Name $rgDiagnostic -ErrorAction Stop | Out-Null
} catch {
    New-AzResourceGroup -Name $rgDiagnostic -Location $location -Tag $tags | Out-Null
}

# Create the LAW if no exist
try {
    Get-AzOperationalInsightsWorkspace -ResourceGroupName $rgDiagnostic -Name $WorkspaceName -ErrorAction Stop | Out-Null
} catch {
    New-AzOperationalInsightsWorkspace -ResourceGroupName $rgDiagnostic -Name $WorkspaceName -Location $Location -Tag $tags | Out-Null
}

# Create the SAs

# Create the SA for prd if no exists
try {
    Get-AzStorageAccount -ResourceGroupName $rgDiagnostic -Name $saProd -ErrorAction Stop | Out-Null
} catch {
    New-AzStorageAccount -ResourceGroupName $rgDiagnostic -Name $saProd -Location $location -SkuName Standard_GRS -Kind StorageV2 -AccessTier Hot -Tag $tags | Out-Null
}

# Create the SA for prd if no exists
try {
    Get-AzStorageAccount -ResourceGroupName $rgDiagnostic -Name $saNonProd -ErrorAction Stop | Out-Null
} catch {
    New-AzStorageAccount -ResourceGroupName $rgDiagnostic -Name $saNonProd -Location $location -SkuName Standard_LRS -Kind StorageV2 -AccessTier Hot -Tag $tags | Out-Null
}

###########
# Networking
###########

# Create the resource group for networking if needed
try {
    Get-AzResourceGroup -Name $rgNetwork -ErrorAction Stop | Out-Null
} catch {
    New-AzResourceGroup -Name $rgNetwork -Location $location -Tag $tags | Out-Null
}

# rt deployment

# Create the rt if no exists
try {
    Get-AzRouteTable -Name $rtName -ResourceGroupName $rgNetwork -ErrorAction Stop | Out-Null
} catch {
    New-AzRouteTable -Name $rtName -ResourceGroupName $rgNetwork -location $location -DisableBgpRoutePropagation -Tag $tags | Out-Null
}

# required set up variables for rt for further rt association
$rt = Get-AzRouteTable -Name $rtName -ResourceGroupName $rgNetwork
# may very on different routing demands
# setting up routs
# route Default
try {
    (Get-AzRouteTable -ResourceGroupName $rgNetwork -Name $rt.Name).Routes | Where-Object Name -like $route_default -ErrorAction Stop | Out-Null
} catch {
    Get-AzRouteTable -ResourceGroupName $rgNetwork -Name $rt.Name | Add-AzRouteConfig -Name $route_default -AddressPrefix $route_default_prefix -NextHopType $route_default_NextHopType -NextHopIpAddress $route_default_NextHopIpAddress | Set-AzRouteTable  | Out-Null
}

# route 1
try {
    (Get-AzRouteTable -ResourceGroupName $rgNetwork -Name $rt.Name).Routes | Where-Object Name -like $route_1 -ErrorAction Stop | Out-Null
} catch {
    Get-AzRouteTable -ResourceGroupName $rgNetwork -Name $rt.Name | Add-AzRouteConfig -Name $route_1 -AddressPrefix $route_1_prefix -NextHopType $route_1_NextHopType -NextHopIpAddress $route_1_NextHopIpAddress | Set-AzRouteTable  | Out-Null
}

# vnet and snet deployment
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $snetName -AddressPrefix $vnetAddress 

try {
    Get-AzVirtualNetwork -ResourceGroupName $rgNetwork -Name $vnetName -ErrorAction Stop | Out-Null
} catch {
    New-AzVirtualNetwork -ResourceGroupName $rgNetwork -Name $vnetName -Location $location -AddressPrefix $snetAddress -Subnet $subnetConfig -DnsServer $dns -Tag $tags  | Out-Null
}

# required set up variables for vnet and snet for further rt association
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgNetwork
$snet = Get-AzVirtualNetworkSubnetConfig -Name $snetName -VirtualNetwork $vnet
# rt to snet association
Set-AzVirtualNetworkSubnetConfig -Name $snet.Name -VirtualNetwork $vnet -AddressPrefix $snet.AddressPrefix -RouteTable $rt  | Out-Null
Set-AzVirtualNetwork -VirtualNetwork $vnet  | Out-Null

###########
# Backup
###########

# Production RSV deployment 
# Create the resource group for backup vaults if needed
try {
    Get-AzResourceGroup -Name $rgBackupRSV -ErrorAction Stop | Out-Null
} catch {
    New-AzResourceGroup -Name $rgBackupRSV -Location $location -Tag $tags | Out-Null
}

# Create the resource group for recovery points if needed
try {
    Get-AzResourceGroup -Name $rgBackupRP -ErrorAction Stop | Out-Null
} catch {
    New-AzResourceGroup -Name $rgBackupRP -Location $location -Tag $tags | Out-Null
}

## Create the Production Recovery Services vault if it does not exist
try {
    Get-AzRecoveryServicesVault -ResourceGroupName $rgBackupRSV -Name $rsvNameProd -ErrorAction Stop | Out-Null
} catch {
    New-AzRecoveryServicesVault -ResourceGroupName $rgBackupRSV -Name $rsvNameProd -Location $location -Tag $tags | Out-Null
}
# Setting up prod vault context
Get-AzRecoveryServicesVault -Name $rsvNameProd | Set-AzRecoveryServicesVaultContext

# Getting Non-Prod retention
$SchPolProd = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
$SchPolProd.ScheduleRunTimes.Clear()

$timeZone = (Get-TimeZone -ListAvailable | Where-Object { $_.id -match "Romance" }).id 
$Date = Get-Date -Hour '19' -Minute '00' -Second '00' -Millisecond '00'
$Date = [DateTime]::SpecifyKind($Date,[DateTimeKind]::Utc)
$SchPolProd.ScheduleRunTimes.Add($Date)
$SchPolProd.ScheduleRunTimeZone = $timeZone

$RetPolProd = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
$RetPolProd.DailySchedule.DurationCountInDays = '14'
$RetPolProd.WeeklySchedule.DurationCountInWeeks = '4'
$RetPolProd.MonthlySchedule.DurationCountInMonths = '12'
$RetPolProd.YearlySchedule.DurationCountInYears = '10'

try {
    Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyProdName -ErrorAction Stop | Out-Null
} catch {
    New-AzRecoveryServicesBackupProtectionPolicy -Name $policyProdName -WorkloadType "AzureVM" -RetentionPolicy $RetPolProd -SchedulePolicy $SchPolProd | Out-Null
}

# setting up RG for RP collection
$Pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyProdName
$Pol.AzureBackupRGName = $rgBackupRP
Set-AzRecoveryServicesBackupProtectionPolicy -Policy $Pol

## Set the diagnostic settings (log and metrics) for the Recovery Services vault if they don't exist
 
try {
    Get-AzDiagnosticSetting -Name $vaultDiagnosticsName -ResourceId ((Get-AzRecoveryServicesVault -Name $rsvNameProd).ID) -ErrorAction Stop | Out-Null
} catch {    
    Set-AzDiagnosticSetting -Name $vaultDiagnosticsName -ResourceId ((Get-AzRecoveryServicesVault -Name $rsvNameProd).ID) `
    -Category AzureBackupReport,CoreAzureBackup,AddonAzureBackupJobs,AddonAzureBackupAlerts,AddonAzureBackupPolicy,AddonAzureBackupStorage,AddonAzureBackupProtectedInstance `
    -MetricCategory Health -Enabled $true -WorkspaceId ((Get-AzOperationalInsightsWorkspace | Where-Object Name -EQ $WorkspaceName).ResourceId) | Out-Null
}

# Non-Production RSV deployment 
## Create the Non-Production Recovery Services vault if it does not exist
try {
    Get-AzRecoveryServicesVault -ResourceGroupName $rgBackupRSV -Name $rsvNameNonProd -ErrorAction Stop | Out-Null
} catch {
    New-AzRecoveryServicesVault -ResourceGroupName $rgBackupRSV -Name $rsvNameNonProd -Location $location -Tag $tags | Out-Null
}
# Setting up non-prod vault context
Get-AzRecoveryServicesVault -Name $rsvNameNonProd | Set-AzRecoveryServicesVaultContext

# Getting Non-Prod retention
$SchPolNonProd = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
$SchPolNonProd.ScheduleRunTimes.Clear()

$timeZone = (Get-TimeZone -ListAvailable | Where-Object { $_.id -match "Romance" }).id 
$Date = Get-Date -Hour '19' -Minute '00' -Second '00' -Millisecond '00'
$Date = [DateTime]::SpecifyKind($Date,[DateTimeKind]::Utc)
$SchPolNonProd.ScheduleRunTimes.Add($Date)
$SchPolNonProd.ScheduleRunTimeZone = $timeZone

$RetPolNonProd = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
$RetPolNonProd.DailySchedule.DurationCountInDays = '14'
$RetPolNonProd.WeeklySchedule.DurationCountInWeeks = '4'
$RetPolNonProd.MonthlySchedule.DurationCountInMonths = '3'
$RetPolNonProd.IsYearlyScheduleEnabled = $false

try {
    Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyNonProdName -ErrorAction Stop | Out-Null
} catch {
    New-AzRecoveryServicesBackupProtectionPolicy -Name $policyNonProdName -WorkloadType "AzureVM" -RetentionPolicy $RetPolNonProd -SchedulePolicy $SchPolNonProd | Out-Null
}

# setting up RG for RP collection
$Pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyNonProdName
$Pol.AzureBackupRGName = $rgBackupRP
Set-AzRecoveryServicesBackupProtectionPolicy -Policy $Pol

Get-AzRecoveryServicesVault -Name $rsvNameNonProd | Set-AzRecoveryServicesBackupProperty -BackupStorageRedundancy LocallyRedundant

## Set the diagnostic settings (log and metrics) for the Recovery Services vault if they don't exist
 
try {
    Get-AzDiagnosticSetting -Name $vaultDiagnosticsName -ResourceId ((Get-AzRecoveryServicesVault -Name $rsvNameNonProd).ID) -ErrorAction Stop | Out-Null
} catch {    
    Set-AzDiagnosticSetting -Name $vaultDiagnosticsName -ResourceId ((Get-AzRecoveryServicesVault -Name $rsvNameNonProd).ID) `
    -Category AzureBackupReport,CoreAzureBackup,AddonAzureBackupJobs,AddonAzureBackupAlerts,AddonAzureBackupPolicy,AddonAzureBackupStorage,AddonAzureBackupProtectedInstance `
    -MetricCategory Health -Enabled $true -WorkspaceId ((Get-AzOperationalInsightsWorkspace | Where-Object Name -EQ $WorkspaceName).ResourceId) | Out-Null
}