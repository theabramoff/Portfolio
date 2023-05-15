#list of variables

variable "prefix" {
  type        = string
  description = "project prefix"
  default     = "aks-egress"
}

variable "resource_group_name" {
  type        = string
  description = "RG name in Sub 01"
  default     = "rg-az01-aks-egress"
}


variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "west europe"
}

variable "vnet" {
  type        = string
  description = "vnet for ask"
  default     = "vnet-az01-aks-egress"
}

variable "snetask" {
  type        = string
  description = "aks snet"
  default     = "aks-subnet"
}

variable "snetfw" {
  type        = string
  description = "AFW snet"
  default     = "AzureFirewallSubnet"
}

variable "pipafw" {
  type        = string
  description = "PIP for AFW"
  default     = "pip-az01-aks-egress"
}

variable "afw" {
  type        = string
  description = "AFW"
  default     = "fw-az01-aks-egress"
}

variable "rt" {
  type        = string
  description = "AFW Route table "
  default     = "fwrt-az01-aks-egress"
}

variable "cluster_name" {
  type        = string
  description = "AKS cluster name"
  default     = "aks-az01-aks-egress"
}

variable "kubernetes_version" {
  type        = string
  description = "version of ASK cluster"
  default     = "1.21.9"
}

variable "system_node_count" {
  type        = number
  description = "AKS worker nodes"
  default     = 3
}

variable "pods_per_node" {
  type        = number
  description = "AKS pods per nodes"
  default     = 50
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
