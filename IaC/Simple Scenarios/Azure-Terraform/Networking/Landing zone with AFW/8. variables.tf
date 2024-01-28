#list of variables

variable "resource_group_name" {
  description = "Name of resource group"
  default     = ""
  type        = string
}

variable "create_resource_group" {
  description = "Set to true if the resource group should be created, set to false if an existing rg should be reused"
  default     = true
  type        = bool
}

variable "project_tags" {
  type        = map(string)
  description = "tags for resources"

# Replace < ... > with tags

  default = {
    "Region" : "< ... >",
    "OwnedBy" : "< ... >",
    "OwnerBackupPerson" : "< ... >",
    "ITOwnerGroup" : "< ... >",
    "Description" : "< ... >",
    "LifecycleEnd" : "< ... >"
    "BuiltBy" = "Terraform"
  }
}

variable "project_name" {
  type        = string
  description = "Default project name extention"
  default     = "01-infra-hub"
}

variable "environment" {
  type        = string
  description = "DEV as default environment"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created, default is East US"
  default     = "East US"
}

variable "location_code" {
  type        = string
  description = "Location code for naming convention"
  default     = "eu"
}

variable "subscription_code" {
  type        = string
  description = "Subscription code for naming convention"
  default     = "01"
}

variable "vnet_hub_segment" {
  type    = string
  default = "10.10.10.0/24"
}

variable "subnet_bastion" {
  type    = string
  default = "10.10.10.0/26"
}

variable "subnet_appgtw" {
  type    = string
  default = "10.10.10.64/26"
}

variable "subnet_firewall" {
  type    = string
  default = "10.10.10.128/26"
}

variable "dns_zone" {
  type        = string
  description = "Azure Private DNS Zone"
  default     = "azfw.theabramoff.pro"
}

variable "firewall_sku_tier" {
  type        = string
  description = "Firewall SKU"
  default     = "Standard" # Valid values are Standard and Premium
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "The sku must be one of the following: Standard, Premium"
  }
}

variable "bastion_sku" {
  type        = string
  description = "Bastion SKU"
  default     = "Basic" # Valid values are Basic and Standard
  validation {
    condition     = contains(["Basic", "Standard"], var.bastion_sku)
    error_message = "The sku must be one of the following: Basic, Standard"
  }
}