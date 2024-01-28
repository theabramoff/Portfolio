#########################################
# Az module required
# The script does the following:
# 1. Dumps VMs and SUM of its VHDs within a subscription 
# 2. Compares the VM name within Azure Reservations 
# 3. Uploads results to csv
#
# The scrip can be used in cases when it's requird to compare Systems with existing reservations which were purchised for a particular VM 
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
$Subscription = "< ... >"

#Create an array = 0
$array = @()

# Select subscription
Select-AzSubscription $Subscription

# Get all VMs in subscription
$VMs= Get-AzVM

    # get a VM from all VMs 
    Foreach ($VM in $VMs)
        {
        Write-Host "Working on $($VM.Name)"

        $VmSize    = $VM.HardwareProfile.VmSize
        $VmSizeCPU = (Get-AzVMSize -Location $VM.Location | Where-Object {$_.name -eq $VmSize }).NumberOfCores
        $VmSizeRAM = ((Get-AzVMSize -Location $VM.Location | Where-Object {$_.name -eq $VmSize }).MemoryInMB) / 1024
        $VHDsizeInGB = (Get-AzDisk | Where-Object ManagedBy -Match $VM.name | Select-Object DiskSizeGB | Measure-Object -sum DiskSizeGB).Sum
        $ARI = Get-AzReservationOrder | Where-Object {($_.ProvisioningState -eq "Succeeded" -or $_.ProvisioningState -eq "Expiring") -and $_.DisplayName -like "*$($VM.Name)*" }

            If ( $null -ne $ARI )
            {
                $ARIterm = $ARI.Term
                $ARIexpiration = (Get-AzReservation -ReservationOrderId $ARI.Name).ExpiryDate.ToString("dd/MM/yyyy")
            }
                else
                {
                    $ARIterm = "No"
                    $ARIexpiration = "No"
                }

        $array += New-Object PSObject -Property @{
            Subscription= "$Subscription"; 
            VM = "$($VM.name)"; 
            VmSize = "$VmSize"; 
            VmSizeCPU = "$VmSizeCPU"; 
            VmSizeRAM = "$VmSizeRAM"; 
            VHDsizeInGB = "$VHDsizeInGB"; 
            ARI = "$ARIterm"; 
            ARIexpiration = "$ARIexpiration"
            }
             
       }

$array | Export-Csv -NoTypeInformation -Path $file

Write-Host "The Information is written to the $file"
# Stop timer
$watch.Stop()
Write-Host $watch.Elapsed

