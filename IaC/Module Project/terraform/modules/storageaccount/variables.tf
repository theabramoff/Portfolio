variable "resource_group_name" {
  description = "Name of existing resource group to reuse"
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

variable "rg_suffix" {
  type = string
}

variable "sa_suffix" {
  type = string
}


variable "environment" {
  type = string
}

variable "redundancy" {
  type = string
  default = "LRS"
}

variable "instance_count" {
  type    = number
  default = 1
}
