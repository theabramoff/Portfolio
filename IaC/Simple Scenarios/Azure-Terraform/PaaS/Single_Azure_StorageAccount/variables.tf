#Variables

# azure region
variable "location" {
  type = string
  description = "Azure region where resources will be created"
  default = "west europe"
}

variable "resourcegroupname" {
  type = string
  description = "RG name"
  default = "rg-az01-Abramov-terraform-test"
}

#storage account name
variable "storage" {
    type = string
    description = "storage account name"
    default = "sa0101tftst"
}
#storage account redundancy
variable "redundancy"{
    type = string
    description = "redundancy"
    default = "LRS"
    }