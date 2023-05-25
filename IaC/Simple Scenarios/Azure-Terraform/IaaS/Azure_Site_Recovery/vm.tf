

resource "azurerm_virtual_machine" "tf-vm" {
  name                = var.vmname
  resource_group_name = azurerm_resource_group.tf-rg-we.name
  location            = var.location-we
  vm_size             = var.vmsku
  license_type        = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.tf-nic.id
  ]
  storage_image_reference {
    publisher = var.win_vm_image_publisher
    offer     = var.win_vm_image_offer
    sku       = var.win_sku
    version   = "latest"
  }


 storage_os_disk {
    name              = "vhd-${var.vmname}-OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vmname
    admin_username      = "sysadmin"
    admin_password      = random_password.win-vm-password.result
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_subnet_network_security_group_association.tf-nsg-association-we

  ]  
}

###
resource "azurerm_managed_disk" "tf-Disk-01" {
  name                 = "vhd-${var.vmname}-Data-01"
  location             = azurerm_resource_group.tf-rg-we.location
  resource_group_name  = azurerm_resource_group.tf-rg-we.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128  
 
 depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne
  ]
 }

 resource "azurerm_managed_disk" "tf-Disk-02" {
  name                 = "vhd-${var.vmname}-Data-02"
  location             = azurerm_resource_group.tf-rg-we.location
  resource_group_name  = azurerm_resource_group.tf-rg-we.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128  
 
 depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne
  ]
 }

resource "azurerm_virtual_machine_data_disk_attachment" "tf-Lun1" {
  managed_disk_id    = azurerm_managed_disk.tf-Disk-01.id
  virtual_machine_id = azurerm_virtual_machine.tf-vm.id
  lun                = "1"
  caching            = "none"

 depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_virtual_machine.tf-vm
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "tf-Lun2" {
  managed_disk_id    = azurerm_managed_disk.tf-Disk-02.id
  virtual_machine_id = azurerm_virtual_machine.tf-vm.id
  lun                = "2"
  caching            = "none"

 depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_virtual_machine.tf-vm
  ]

}