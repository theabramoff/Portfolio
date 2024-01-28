 # Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file1="C:\Temp\Azure-Total-Reserved-vCPUs_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv",
    [string]$file2="C:\Temp\Azure-Total-vCPUs_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 
# Start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

#Create 2 arrays = 0
$dataARIs = @()       
$dataVMs  = @() 

# Authenticate Azure portal
#Connect-AzAccount

$Subscriptions = (Get-AzSubscription).Name      

$ARIs = Get-AzReservationOrder | ?{($_.ProvisioningState -eq "Succeeded" -or $_.ProvisioningState -eq "Expiring")}
        
Foreach ( $ARI in $ARIs )
{
    Write-Host "working on $($ARI.DisplayName)"        
    $ARItype = (Get-AzReservation -ReservationOrderId $ARI.Name).ReservedResourceType
                
        If ( $ARItype -eq "VirtualMachines")
        {
            $ARIlocation = (Get-AzReservation -ReservationOrderId $ARI.Name).Location
            $ARIquantity = (Get-AzReservation -ReservationOrderId $ARI.Name).Quantity
            $ARIsku = (Get-AzReservation -ReservationOrderId $ARI.name).Sku
            $ARIskuCPU = (Get-AzVMSize -Location $ARIlocation | ?{ $_.name -eq $ARIsku }).NumberOfCores
            $vCPUsReserved = $ARIskuCPU * $ARIquantity


            $dataARIs += [PSCustomObject]@{
                ARIs = "$($ARI.DisplayName)";
                Count = $vCPUsReserved;
            } 
        }

        else
            {
            Write-Host "$($ARI.DisplayName) is $((Get-AzReservation -ReservationOrderId $ARI.Name).ReservedResourceType)"
            }     
   
}
Write-Host "Finished with ARIs"

Foreach ($Subscription in $Subscriptions)
{
    Select-AzSubscription $Subscription #| Out-Null 
    $VMs = Get-AzVM
        Foreach ($VM in $VMs)
        {
        $VmSize    = $VM.HardwareProfile.VmSize
        $VmSizeCPU = (Get-AzVMSize -Location $VM.Location | ?{ $_.name -eq $VmSize }).NumberOfCores
    
            $dataVMs += [PSCustomObject]@{
                Subscription = $Subscription;
                VM = "$($VM.name)";
                VmSizeCPU = $VmSizeCPU;
                }
        }
}
Write-Host "Finished with VMs" 

$reservedVCpus = ($dataARIs | Measure-Object -Property Count -Sum).Sum
$totalVCpus = ($dataVMs | Measure-Object -Property VmSizeCPU -Sum).Sum

$percentageReserved = (($reservedVCpus / $totalVCpus ) * 100).ToString("0.00")

Write-Host "Capacity reserved $($percentageReserved) %"

$dataARIs | Export-Csv -NoTypeInformation -Path $file1
$dataVMs | Export-Csv -NoTypeInformation -Path $file2

Write-Host "Drive list is written to the $($file1) and $($file2)"
# Stop timer
$watch.Stop()
Write-Host $watch.Elapsed
