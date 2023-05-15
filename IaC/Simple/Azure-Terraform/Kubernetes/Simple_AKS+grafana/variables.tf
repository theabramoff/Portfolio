
variable "resource_group_name" {
  type        = string
  description = "RG name in Sub 01"
  default     = "rg-az01-aks-abramov-test"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "west europe"
}

variable "vnet" {
  type        = string
  description = "vnet for ask"
  default     = "vnet-az01-aks-abramov-test"
}

variable "nsg" {
  type        = string
  description = "vnet for ask"
  default     = "nsg-az01-aks-abramov-test"
}

variable "cluster_name" {
  type        = string
  description = "AKS cluster name"
  default     = "aks-abramov-trf-test"
}

variable "kubernetes_version" {
  type        = string
  description = "version of ASK cluster"
  default     = "1.21.9"
}

variable "system_node_count" {
  type        = number
  description = "AKS worker nodes"
  default     = 2
}

variable "arc_name" {
  type        = string
  description = "ARC name"
  default     = "acrabramovtrftest"
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
