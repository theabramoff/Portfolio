#########################################
# Az module required
# the script deployes a single VHD in a sungle subscription
#########################################

# Authenticate Azure portal
Connect-AzAccount

#declare Subscription, RG and VM name
# Replace < ... > with Subscription name
$subscription = "< ... >"
# Replace < ... > with rg name
$rg = "< ... >"
# Replace < ... > with vm name
$vm = "< ... >"

# Choose between Standard_LRS, StandardSSD_LRS and Premium_LRS based on your scenario
$storageType = "Standard_LRS"   #uses Standard HDD
#$storageType = "StandardSSD_LRS"    #uses uses Premium SSD
#$storageType = "Premium_LRS"    #uses uses Premium SSD

Select-AzSubscription $subscription

$vmName = Get-AzVM -ResourceGroupName $rg -Name $vm

#check VM status
$statuscheck = Get-AzVM -ResourceGroupName $rg -Name $vm -Status 
    if($statuscheck.Statuses.DisplayStatus[1] -eq "VM running")
    {  

        Write-Output "The VM - $vm is Running...Deallocating..."

        Stop-AzVM -ResourceGroupName $rg -Name $vm -Force
    }   
    else
    {
        Write-output "The VM - $vm is already deallocated"
    }


# Get all disks in the resource group of the VM
$vmDisks = Get-AzDisk -ResourceGroupName $rg 

# For disks that belong to the selected VM, convert to Premium storage
foreach ($disk in $vmDisks)
{
	if ($disk.ManagedBy -eq $vmName.Id)
	{
		$disk.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
		$disk | Update-AzDisk
        Write-Host $disk.Name"is updated"
	}
}

#enable if start required
#Start-AzVM -ResourceGroupName $rgName -Name $vmName