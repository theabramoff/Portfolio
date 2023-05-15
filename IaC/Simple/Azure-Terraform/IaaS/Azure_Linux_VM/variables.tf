
variable "prefix" {
  type        = string
  description = "prefix"
  default     = "az01-linux-test-vm"
}

variable "resource_group_name" {
  type        = string
  description = "RG name in Sub 01"
  default     = "rg-az01-linux-test-vm"
}

variable "tags" {
  description = "The tags to associate with the resources"
  type        = map(string)

  default = {
    Description       = "Test Linux VM"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31DEC2023"
  }
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "west europe"
}

variable "vnet" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "vnet-az01-linux-test-vm"
}

variable "snet" {
  type        = string
  description = "Azure snet"
  default     = "snet01"
}

variable "vmname" {
  type        = string
  description = "Azure vm"
  default     = "az01-lvm-01"
}

variable "vmsku" {
  type        = string
  description = "Azure SKU"
  default     = "Standard_B2s"
}

variable "linux_vm_image_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "RedHat"
}

variable "linux_vm_image_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "RHEL"
}

variable "rhel_7_8_sku" {
  type        = string
  description = "SKU for RHEL 7.8"
  default     = "7.8"
}