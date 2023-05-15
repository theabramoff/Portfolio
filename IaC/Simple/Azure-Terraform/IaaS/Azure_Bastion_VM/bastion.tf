# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.80.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "tf-rg" {
    name     = "rg-az01-abramov-terraform"
    location = "westeurope"

    tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}

# create private DNS zone
resource "azurerm_private_dns_zone" "tf-dns" {
  name                = "abramov.com"
  resource_group_name = azurerm_resource_group.tf-rg.name

      tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}

# Create virtual network 
resource "azurerm_virtual_network" "tf-network-hub" {
    name                = "vnet-az01-abramov-terraform"
    address_space       = ["10.1.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.tf-rg.name

        tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}

# Create subnet for vm
resource "azurerm_subnet" "tf-subnet-vm" {
    name                 = "vm-subnet"
    resource_group_name  = azurerm_resource_group.tf-rg.name
    virtual_network_name = azurerm_virtual_network.tf-network-hub.name
    address_prefixes       = ["10.1.0.0/24"]
}

# Create subnet for Bastion
resource "azurerm_subnet" "tf-subnet-bastion" {
    name                 = "AzureBastionSubnet"
    resource_group_name  = azurerm_resource_group.tf-rg.name
    virtual_network_name = azurerm_virtual_network.tf-network-hub.name
    address_prefixes       = ["10.1.1.0/27"] 
}

# Basion Public IP
resource "azurerm_public_ip" "tf-bastion-pip" {
  name                = "pip-az01-AzureBastion"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

    tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}

resource "azurerm_bastion_host" "tf-bastion" {
  name                = "azbst-az01-abramov-terraform"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.tf-subnet-bastion.id
    public_ip_address_id = azurerm_public_ip.tf-bastion-pip.id
  }

    tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}

#link private DNS zone with vNet
resource "azurerm_private_dns_zone_virtual_network_link" "tf-dns-link-01" {
  name                  = "abramov.com-to-vnet"
  resource_group_name   = azurerm_resource_group.tf-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.tf-dns.name
  virtual_network_id    = azurerm_virtual_network.tf-network-hub.id
  registration_enabled  = "true"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "tf-nsg-01" {
    name                = "nsg-az01-01-abramov-terraform"
    location            = azurerm_resource_group.tf-rg.location
    resource_group_name = azurerm_resource_group.tf-rg.name

    #security_rule {
       # name                       = "RDP"
       # priority                   = 100
       # direction                  = "Inbound"
      #  access                     = "Allow"
      #  protocol                   = "Tcp"
      #  source_port_range          = "*"
       # destination_port_range     = "3389"
       # source_address_prefix      = "*"
       # destination_address_prefix = "*"
    #}

    tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}

# NSG accosiation
resource "azurerm_subnet_network_security_group_association" "tf-nsg-to-snet-vm-01" {
  subnet_id                 = azurerm_subnet.tf-subnet-vm.id
  network_security_group_id = azurerm_network_security_group.tf-nsg-01.id
}

# NIC creation
resource "azurerm_network_interface" "tf-nic-aav-01" {
    name                      = "nic-az01-aav-01"
    location                  = "westeurope"
    resource_group_name       = azurerm_resource_group.tf-rg.name
    enable_accelerated_networking = "true"

    ip_configuration {
        name                          = "NicConfiguration01"
        subnet_id                     = azurerm_subnet.tf-subnet-vm.id
        private_ip_address_allocation = "Dynamic"
        #private_ip_address            = "10.1.0.5"
        #private_ip_address_allocation = "static"
        #public_ip_address_id          = azurerm_public_ip.tf-pip.id   
    }

    tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}
# Azure VM creation, replace < ... > with password
resource "azurerm_windows_virtual_machine" "tf-AzVM-aav-01" {
  name                  = "az01-aav-01"
  resource_group_name   = azurerm_resource_group.tf-rg.name
  location              = azurerm_resource_group.tf-rg.location
  size                  = "Standard_E2s_v3"
  admin_username        = "sysadmin"
  admin_password        = "< ... >"
  license_type          = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.tf-nic-aav-01.id
  ]

  os_disk {
    name                 = "vhd-az01-aav-01-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

    tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
}
#managed disk creation
resource "azurerm_managed_disk" "tf-AzVMDisk01-aav-01" {
  name                 = "vhd-az01-aav-01-data01"
  location             = azurerm_resource_group.tf-rg.location
  resource_group_name  = azurerm_resource_group.tf-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128  

    tags = {
        Environment = "Terraform Abramov"
        Description = "new RG for terraform test"
        OwnedBy = "Abramov, Andrey"
        OwnerBackupPerson = "N/A"
    }
 }

#managed disk attachment
resource "azurerm_virtual_machine_data_disk_attachment" "tf-AzVMDisk01-aav-01-Lun1" {
  managed_disk_id    = azurerm_managed_disk.tf-AzVMDisk01-aav-01.id
  virtual_machine_id = azurerm_windows_virtual_machine.tf-AzVM-aav-01.id
  lun                = "1"
  caching            = "Readonly"
}


#BACKLOG:
# Connect the security group to the network interface
# resource "azurerm_subnet_network_security_group_association" "TFnsgAssos" {
 # subnet_id                 = azurerm_subnet.tf-subnet-vm.id
  #network_security_group_id = azurerm_network_security_group.tf-nsg.id
#