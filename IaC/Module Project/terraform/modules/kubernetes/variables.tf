variable "resource_group_name" {
  description = "Name of resource group"
  default = ""
  type = string
}

variable "create_resource_group" {
  description = "Set to true if the resource group should be created, set to false if an existing rg should be reused"
  default = true
  type = bool
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

variable "project_name" {
  type = string
}

variable "project_tags" {
  type        = map(string)
  description = "tags for resources"

  default = {
    BuiltBy = "Terraform"
  }
}

variable "environment" {
  type = string
}

variable "vnet_segment" {
  type = string
}

variable "subnet" {
  type = string
}

variable "service_cidr" {
  type = string
}

variable "dns_ip" {
  type = string
}

variable "kubernetes_version" {
  description = "aks version"
  default = "1.23.12"
  type = string
}

variable "system_node_count" {
  description = "master nodes"
  default = "1"
  type = string
}

variable "worker_node_count" {
  description = "worker nodes"
  default = "1"
  type = string
}

variable "pods_per_node" {
  description = "pods nodes"
  default = "30"    #   max 110
  type = string
}

variable "vm_size_system" {
  description = "vm size"
  default = ""    #   max 110 Standard_B2s
  type = string
}

variable "vm_size_worker" {
  description = "vm size"
  default = ""    #   max 110
  type = string
}

variable "autoscaling" {
  description = "autoscaling for AKS"
  default = false
  type = bool
}

variable "private" {
  description = "private or public cluster"
  default = false
  type = bool
}

variable "os_disk_size" {
  description = "OS drive size"
  default = "30"
  type = string
}

variable "dns" {
  type = list
}

#variable "api_authorized_ip" {
  #type = list
#}

variable "routes" {
  description = "routs in rt"
  type = list(object({
    name                 = string
    address_prefix       = string
    next_hop_type        = string
    next_hop_in_ip_address = string
  }))
  default = []
}

variable "disable_bgp_route_propagation" {
  description = "Flag  controls propagation of routes learned by BGP on that route table."
  type        = bool
  default     = true
}

