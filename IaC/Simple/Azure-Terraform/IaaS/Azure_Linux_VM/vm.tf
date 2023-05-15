



resource "azurerm_network_interface" "tf-nic" {
  name                = "nic-${var.vmname}"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf-pip.id
  }
}

resource "azurerm_linux_virtual_machine" "tf-vm" {
  name                = var.vmname
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  size                = var.vmsku
  admin_username      = "sysadmin"
  admin_password      = random_password.linux-vm-password.result
  network_interface_ids = [
    azurerm_network_interface.tf-nic.id
  ]

  os_disk {
    name = "vhd-${var.vmname}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.linux_vm_image_publisher
    offer     = var.linux_vm_image_offer
    sku       = var.rhel_7_8_sku
    version   = "latest"
  }

    disable_password_authentication = false

}
###
resource "azurerm_managed_disk" "tf-Disk-01" {
  name                 = "vhd-${var.vmname}-Data-01"
  location             = azurerm_resource_group.tf-rg.location
  resource_group_name  = azurerm_resource_group.tf-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128  
 }

 resource "azurerm_managed_disk" "tf-Disk-02" {
  name                 = "vhd-${var.vmname}-Data-02"
  location             = azurerm_resource_group.tf-rg.location
  resource_group_name  = azurerm_resource_group.tf-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128  
 }


resource "azurerm_virtual_machine_data_disk_attachment" "tf-Lun1" {
  managed_disk_id    = azurerm_managed_disk.tf-Disk-01.id
  virtual_machine_id = azurerm_linux_virtual_machine.tf-vm.id
  lun                = "1"
  caching            = "none"
}

resource "azurerm_virtual_machine_data_disk_attachment" "tf-Lun2" {
  managed_disk_id    = azurerm_managed_disk.tf-Disk-02.id
  virtual_machine_id = azurerm_linux_virtual_machine.tf-vm.id
  lun                = "2"
  caching            = "none"

}