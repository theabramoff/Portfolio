module "vm-01" {
  source = "../../../modules/single-linux-vm"
  
  #instances_count         = 1
  subsequent_vm_number   = "01"
  

  subscription_code       = var.subscription_code
  resource_group_name     = var.resource_group_name
  resource_group_location = var.location
  location                = var.location
  location_code           = var.location_code

  project_name            = "abramov-tf-vm"
  environment             = "test"
  #vnet for VM
  vnet_segment            = "10.10.0.0/24"
  subnet                  = "10.10.0.0/24"

  nsg_inbound_rules = [
      {
        name                   = "ssh"
        destination_port_range = "22"
        source_address_prefix  = "*"
      },
      {
        name                   = "http"
        destination_port_range = "80"
        source_address_prefix  = "*"
      }
    ]

  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "disk2"
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
    }
  ]  

  #tagging
  project_tags = {
      "Region":"USA",
      OwnedBy:"Abramov, Andrey",
      OwnerBackupPerson:"N/A",
      ITOwnerGroup:"N/A",
      "Description":"VM for test",
      "Lifecycle End":"31DEC2023"
    }
}

output "ubuntu-vm_outputs" {
  value = module.vm-01
}