
variable "prefix-we" {
  type        = string
  description = "prefix"
  default     = "az01-abramov-asr-original-test"
}

variable "prefix-ne" {
  type        = string
  description = "prefix"
  default     = "az01-abramov-asr-replica-test"
}

variable "prefix-ne-asr" {
  type        = string
  description = "prefix"
  default     = "az01-abramov-asr-infrastructure-test"
}

variable "prefix-resource-we" {
  type        = string
  description = "prefix"
  default     = "az01-srv-aa"
}

variable "prefix-resource-ne" {
  type        = string
  description = "prefix"
  default     = "az01-srv-aa"
}

variable "tags" {
  description = "The tags to associate with the resources"
  type        = map(string)

  default = {
    Description       = "Test ASR via TF"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31DEC2023"
    CreatedBy         = "Terraform"
  }
}

variable "location-we" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "west europe"
}

variable "location-ne" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "north europe"
}

variable "vmname" {
  type        = string
  description = "Azure vm"
  default     = "az01-srv-aa"
}

variable "vmsku" {
  type        = string
  description = "Azure SKU"
  default     = "Standard_B2s"
}

variable "win_vm_image_publisher" {
  type        = string
  description = "Virtual machine source image publisher"
  default     = "MicrosoftWindowsServer"
}

variable "win_vm_image_offer" {
  type        = string
  description = "Virtual machine source image offer"
  default     = "WindowsServer"
}

variable "win_sku" {
  type        = string
  description = "Win SKU"
  default     = "2016-Datacenter"
}

#storage account
variable "storage" {
    type = string
    description = "storageaccountname"
    default = "sa0101asr"
}

variable "tier" {
    type = string
    description = "tier for storage account"
    default = "Standard"
}

#storage account redundancy
variable "redundancy"{
    type = string
    description = "redundancy"
    default = "LRS"
    }