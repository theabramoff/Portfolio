#list of variables

variable "prefix" {
  type        = string
  description = "project prefix"
  default     = "az01-aks-poc"
}

variable "tags" {
  description = "The tags to associate with the resources"
  type        = map(string)

  default = {
    Description       = "Azure Kubernetes for poC"
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

# set id ID Group from Azure AD who will be administrate the cluster
variable "admin_aad_group_id" {
  type        = string
  description = "Azure Active Directory admin group"
  default = "< ... >"
}

variable "kubernetes_version" {
  type        = string
  description = "version of ASK cluster"
  default     = "1.21.9"
}

variable "system_node_count" {
  type        = number
  description = "AKS sys nodes"
  default     = 2
}

variable "worker_node_count" {
  type        = number
  description = "AKS sys nodes"
  default     = 3
}

variable "pods_per_node" {
  type        = number
  description = "AKS pods per nodes"
  default     = 30
}

variable "vm_size" {
  type        = string
  description = "VM size for pool"
  default     = "Standard_B2s"
}

variable "os_disk_size" {
  description = "OS Disk size (in GiB) to provision for each of the agent pool nodes."
  default     = 32
}
