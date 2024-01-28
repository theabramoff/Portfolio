 # Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$tenantId="",
    [string]$file="C:\Temp\Azure-CPUs-ARI-ration" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 
# Start timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start()

# Authenticate Azure portal
#Connect-AzAccount

#Create an array = 0
$array = @()       
        
        
$ARIs = Get-AzReservationOrder | ?{($_.ProvisioningState -eq "Succeeded" -or $_.ProvisioningState -eq "Expiring")}
        
Foreach ( $ARI in $ARIs )
{
    Write-Host "working on $($ARI.DisplayName)"            
    $ARItype = (Get-AzReservation -ReservationOrderId $ARI.Name).ReservedResourceType
    $ARIlocation = (Get-AzReservation -ReservationOrderId $ARI.Name).Location
    $ARIquantity = (Get-AzReservation -ReservationOrderId $ARI.Name).Quantity
                
        If ( $ARItype -eq "VirtualMachines")
        {
            $ARIsku = (Get-AzReservation -ReservationOrderId $ARI.name).Sku
            $ARIskuCPU = (Get-AzVMSize -Location $ARIlocation | ?{ $_.name -eq $ARIsku }).NumberOfCores
            $vCPUsReserved = $ARIskuCPU * $ARIquantity
        }
               
            $array += [PSCustomObject]@{
                VMs = "Azure VM CPUs"
                Count = $vCPUsReserved
            }

}

$array | Export-Csv -NoTypeInformation -Path $file

Write-Host "Drive list is written to the  $file"
# Stop timer
$watch.Stop()
Write-Host $watch.Elapsed
