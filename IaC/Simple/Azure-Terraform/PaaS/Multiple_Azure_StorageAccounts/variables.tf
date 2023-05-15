variable "rg" {
  type        = string
  description = "RG for the env"
  default     = "rg-az01-abramov-terraform-demo"
}

variable "tags" {
  description = "The tags to associate with the resources"
  type        = map(string)

  default = {
    Description       = "Demo for Operations"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
  }
}

variable "location" {
  type        = string
  description = "location for the env"
  default     = "westeurope"
}

variable "storage" {
  type        = string
  description = "common storage name"
  default     = "saaz010"
}

variable "redundancy" {
  type        = string
  description = "redundancy for storage"
  default     = "LRS"
}