locals {
rg_name = var.create_resource_group  == true ?  format("rg-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment) : var.resource_group_name 
node_rg_name = format("rg-az%s%s-%s-node-resources-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
aks = format("aks-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
vnet = format("vnet-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
snet = format("snet-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
rt = format("rt-az%s%s-%s-%s", var.location_code, var.subscription_code, var.project_name, var.environment)
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.rg_name}"
  location = var.location
  tags     = var.project_tags
}

#Deploy AKS with outbound type of UDR to the new network
resource "azurerm_kubernetes_cluster" "kubernetes" {
    resource_group_name       = azurerm_resource_group.rg.name
    location                  = azurerm_resource_group.rg.location
    node_resource_group       = "${local.node_rg_name}"
    name                      = "${local.aks}"
    kubernetes_version        = var.kubernetes_version
    dns_prefix                = "${local.aks}"
    private_cluster_enabled   = var.private
    #api_server_authorized_ip_ranges = var.api_authorized_ip

  default_node_pool{
    name                = "systempool"
    node_count          = var.system_node_count
    max_pods            = var.pods_per_node
    vm_size             = var.vm_size_system
    type                = "VirtualMachineScaleSets"
    zones               = [1, 2, 3]
    enable_auto_scaling = var.autoscaling              #false
    max_count           = null
    min_count           = null
    os_disk_size_gb     = var.os_disk_size
    os_disk_type        = "Managed"
    vnet_subnet_id      = azurerm_subnet.snet.id
    
    node_labels = {
      "nodepool-type"    = "system"
      "environment"      =  var.environment    # -->"poc"
      "nodepoolos"       = "linux"
      "app"              = "system-apps" 
  }
  }

  identity {
    type = "SystemAssigned"
  }

/*
# RBAC and Azure AD Integration Block
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      azure_rbac_enabled = true
      admin_group_object_ids = [var.admin_aad_group_id]
    }
  }

*/

  network_profile {
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_ip
    docker_bridge_cidr = "172.17.0.1/16"
    load_balancer_sku  = "standard"
    network_plugin     = "azure"
    network_policy     = "calico"
    outbound_type      = "loadBalancer"
  }

  tags = var.project_tags

  }

  resource "azurerm_kubernetes_cluster_node_pool" "workerpool" {
    name                = "workerpool"
    kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes.id
    node_count          = var.worker_node_count
    max_pods            = var.pods_per_node
    vm_size             = var.vm_size_worker
    zones  = [1, 2, 3]
    enable_auto_scaling = false
    os_disk_size_gb     = var.os_disk_size
    os_disk_type        = "Managed"
    vnet_subnet_id      = azurerm_subnet.snet.id

  tags = var.project_tags 
}