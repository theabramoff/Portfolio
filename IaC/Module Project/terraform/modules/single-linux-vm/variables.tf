variable "resource_group_name" {
  description = "Name of resource group"
  default = ""
  type = string
}

variable "create_resource_group" {
  description = "Set to true if the resource group should be created, set to false if an existing rg should be reused"
  default = true
  type = bool
}

variable "resource_group_location" {
  type = string
}

variable "location" {
  type = string
}

variable "location_code" {
  type = string
}

variable "subscription_code" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_tags" {
  type        = map(string)
  description = "tags for resources"

  default = {
    BuiltBy = "Terraform"
  }
}

variable "vnet_segment" {
  type = string
}

variable "subnet" {
  type = string
}

variable "vm_sku" {
  type        = string
  description = "Azure SKU"
  default     = "Standard_B2s"
}

variable "subsequent_vm_number" {
  type        = string
  description = "subsequent vm number after srv, has to be unique"
}

variable "os_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "Canonical"
}

variable "os_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "0001-com-ubuntu-server-focal"
}

variable "os_sku" {
  type        = string
  description = "SKU for Ubuntu"
  default     = "20_04-lts-gen2"
}

variable "nsg_inbound_rules" {
  description = "List of network rules to apply to network interface."
  default     = []
}

variable "data_disks" {
  description = "Managed Data Disks for azure viratual machine"
  type = list(object({
    name                 = string
    storage_account_type = string
    disk_size_gb         = number
  }))
  default = []
}
/*
variable "instances_count" {
  description = "The number of Virtual Machines required."
  default     = 1
}

variable "instance_number" {
  description = "The number of Virtual Machines required."
  default = {
    "1" = "01"
    "2" = "02"
    "3" = "03"
    "5" = "05"
    "6" = "06"
    "7" = "07"
    "8" = "08"
    "9" = "10"
  }
}
*/

/* RHEL
variable "var.os_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "RedHat"
}

variable "os_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "RHEL"
}

variable "os_sku" {
  type        = string
  description = "SKU for RHEL 7.8"
  default     = "7.8"
}

*/