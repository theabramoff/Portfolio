#########################################
# Az.Reservations module required
#########################################

# Replace < ... > with a path, e.g. c:\temp\
param(
    [string]$file="< ... >\ARI_Audit_" + (get-date -format yyyy) + "_" + (get-date -format MM) + "_" + (get-date -format dd) + ".csv"
) 

$ariObj = @()

# Authenticate Azure portal
Connect-AzAccount

# Get all reservation orders
$reservationOrders = (Get-AzReservationOrder | Where-Object {($_.ProvisioningState -eq "Succeeded" -or $_.ProvisioningState -eq "Expiring") -and ($_.RequestDateTime -gt (get-date).adddays(-1095))}).Name
     
    foreach ($reservationOrder in $reservationOrders) {

        $reservations = Get-AzReservation -ReservationOrderId $reservationOrder

        # Print reservation details with expiration date
        foreach ($reservation in $reservations) {

            $ariInfo = [pscustomobject]@{
            'expirationDate' = $reservation.ExpiryDate.ToString("yyyy-MM-dd")
            'Name' = $reservation.DisplayName
            'reservationOrder'= $reservationOrder
            'reservationID' = $reservation.Name
            'SKU' = $reservation.Sku
            'Scope'= $reservation.AppliedScopeType
            'Quantity'= $reservation.Quantity
            'ProvisioningState' = $reservation.ProvisioningState
            'type' = $reservation.ReservedResourceType
            }
        $ariObj += $ariInfo
        $ariObj | Export-Csv -NoTypeInformation -Path $file
        }
    }
