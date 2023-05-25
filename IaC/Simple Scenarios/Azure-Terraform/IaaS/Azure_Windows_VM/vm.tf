
# replace < ... > with password
resource "azurerm_windows_virtual_machine" "tf-Vm" {
  name                = "az01-srv-01"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  size                = "Standard_E4s_v3"
  license_type        = "Windows_Server"
  admin_username      = "sysadmin"
  admin_password      = "< ... >"
  network_interface_ids = [azurerm_network_interface.tf-nic.id,]
  #azurerm_network_interface.tfnic.id,

  os_disk {
    name                 = "vhd-az01-srv-01-OS"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
    
  }
}

 resource "azurerm_managed_disk" "tf-Data01" {
  name                 = "vhd-az01-srv-01-data01"
  location             = azurerm_resource_group.tf-rg.location
  resource_group_name  = azurerm_resource_group.tf-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128  
 }

 resource "azurerm_managed_disk" "tf-Data02" {
  name                 = "vhd-az01-srv-01-data02"
  location             = azurerm_resource_group.tf-rg.location
  resource_group_name  = azurerm_resource_group.tf-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128  
 }

resource "azurerm_virtual_machine_data_disk_attachment" "tf-Lun1" {
  managed_disk_id    = azurerm_managed_disk.tf-Data01.id
  virtual_machine_id = azurerm_windows_virtual_machine.tf-Vm.id
  lun                = "1"
  caching            = "Readonly"
}

resource "azurerm_virtual_machine_data_disk_attachment" "tf-Lun2" {
  managed_disk_id    = azurerm_managed_disk.tf-Data02.id
  virtual_machine_id = azurerm_windows_virtual_machine.tf-Vm.id
  lun                = "2"
  caching            = "Readonly"
}