#list of variables

variable "rg" {
  type        = string
  description = "rg name"
  default     = "rg-az01-asp-test"
}

variable "tags" {
  description = "The tags to associate with the resources"
  type        = map(string)

  default = {
    Description       = "App service plan 4 test"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31Dec2023"
  }
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "west europe"
}

variable "asp1" {
  type        = string
  description = "asp1 name"
  default     = "AppSvcPln-az01-shared-linux-01-devqa"
}

variable "asp2" {
  type        = string
  description = "asp2 name"
  default     = "AppSvcPln-az01-shared-linux-02-devqa"
}

variable "kind" {
  type        = string
  description = "asp kind"
  default     = "Linux"
}

variable "tier" {
  type        = string
  description = "asp tier"
  default     = "Linux"
}

variable "size" {
  type        = string
  description = "asp size"
  default     = "S1"
}

