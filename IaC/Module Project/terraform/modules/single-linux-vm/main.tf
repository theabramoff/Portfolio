locals {
rg_name = var.create_resource_group  == true ?  format("rg-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment) : var.resource_group_name 
vm_name = format("az%s%s-srv", var.location_code, var.subscription_code)
vnet = format("vnet-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
snet = format("snet-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
nsg = format("nsg-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)

vm_data_disks = { for idx, data_disk in var.data_disks : data_disk.name => {
    idx : idx,
    data_disk : data_disk
    }
  }
}

#---------------------------------------
# Resource group
#---------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = var.project_tags
}

# Generate random password
resource "random_password" "password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true   #number is depricated
  special          = true
  override_special = "!@#$%&"
}

#---------------------------------------
# Virtual machine nic
#---------------------------------------
resource "azurerm_network_interface" "nic" {
  #name                = "nic-${local.vm_name}-${lookup(var.instance_number, count.index + 1)}"
  name                = "nic-${local.vm_name}-${var.subsequent_vm_number}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.pip[count.index].id
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags     = var.project_tags

depends_on = [azurerm_resource_group.rg]
}

#---------------------------------------
# Virtual machine
#---------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  #count               = var.instances_count

  #name                = "${local.vm_name}-${lookup(var.instance_number, count.index + 1)}"
  name                = "${local.vm_name}-${var.subsequent_vm_number}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_sku
  admin_username      = "sysadmin"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.nic.id
    #azurerm_network_interface.nic[count.index].id
  ]

  os_disk {
    #name                = "vhd-${local.vm_name}-${lookup(var.instance_number, count.index + 1)}-OsDisk"
    name = "vhd-${local.vm_name}-${var.subsequent_vm_number}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = "latest"
  }
    disable_password_authentication = false

  tags     = var.project_tags

depends_on = [azurerm_resource_group.rg]
}

#---------------------------------------
# Virtual machine data disks
#---------------------------------------
resource "azurerm_managed_disk" "data_disk" {
  for_each             = local.vm_data_disks
  name                 = "vhd-${local.vm_name}-${var.subsequent_vm_number}-DataDisk-${each.value.idx}"
  #name                 = "vhd-${local.vm_name}-${lookup(var.instance_number, count.index + 1)}-DataDisk-${each.value.idx}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  storage_account_type = lookup(each.value.data_disk, "storage_account_type", "StandardHDD_LRS")
  create_option        = "Empty"
  disk_size_gb         = each.value.data_disk.disk_size_gb
  tags                 = merge({ "ResourceName" = "vhd-${local.vm_name}-${var.subsequent_vm_number}-DataDisk-${each.value.idx}" }, var.project_tags, )
  #tags                 = merge({ "ResourceName" = "vhd-${local.vm_name}-${lookup(var.instance_number, count.index + 1)}-DataDisk-${each.value.idx}" }, var.project_tags, )
  
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
depends_on = [azurerm_resource_group.rg]  
}

#---------------------------------------
# Virtual machine data disks attachment
#---------------------------------------
resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  for_each           = local.vm_data_disks
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  #virtual_machine_id = azurerm_linux_virtual_machine.vm[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = each.value.idx
  caching            = "None"

depends_on = [azurerm_linux_virtual_machine.vm, azurerm_managed_disk.data_disk]
}