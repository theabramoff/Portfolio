variable "location_code" {
    description = "regional code, e.g. we if West Europe, eu if East US etc."
}

variable "subscription_code" {
    description = "Sub code e.g. az01 where code is 90"
}

variable "location" {
    description = "Location for deployment be deployed"
}

variable "resource_group_name" {
  description = "Name of existing resource group to reuse"
  default = ""
  type = string
}

variable "environment" {
  type = string
}
