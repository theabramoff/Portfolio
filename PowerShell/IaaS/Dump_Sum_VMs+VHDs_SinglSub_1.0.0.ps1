#########################################
# Az module required
# The script dumps VMs and SUM of its VHDs within a subscription and uploads to csv
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file="C:\Temp\Azure-ARM-VMs_drives" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 
# Start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

# Authenticate Azure portal
Connect-AzAccount

# Replace < ... > with Subscription name
$sub = "< ... >"

# Create an array = 0
$array = @()

# Select subscription
Select-AzSubscription $sub

# Get all VMs in subscription
$VMs= (Get-AzVM).Name

    # Get a VM from all VMs 
    Foreach ($VM in $VMs)
        {
    Write-Host "Working on $VM"

    $VmSize    = (Get-AzVM -Name $VM).HardwareProfile.VmSize
    $VmSizeCPU = (Get-AzVMSize -Location (Get-AzVM -name $VM).Location | Where-Object {$_.name -eq $VmSize }).NumberOfCores
    $VmSizeRAMinGB = ((Get-AzVMSize -Location (Get-AzVM -name $VM).Location | Where-Object  {$_.name -eq $VmSize }).MemoryInMB) / 1024
    $VmSizeStorageinGB = (Get-AzDisk | Where-Object ManagedBy -Match $VM | Select-Object DiskSizeGB | Measure-Object -sum DiskSizeGB).Sum
    # Updating the Array          
    $array += New-Object PSObject -Property @{Subscription= "$Sub"; VM = "$VM"; VmSize = "$VmSize"; VmSizeCPU = "$VmSizeCPU"; VmSizeRAM = "$VmSizeRAMinGB"; DrivesCapacity = "$VmSizeStorageinGB";}            
       }

$array | Export-Csv -NoTypeInformation -Path $file

Write-Host "The Information is written to the $file"
# Stop timer
$watch.Stop()
Write-Host $watch.Elapsed

