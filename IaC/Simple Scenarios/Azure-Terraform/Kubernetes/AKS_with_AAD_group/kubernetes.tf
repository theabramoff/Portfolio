
#Deploy AKS with outbound type of UDR to the existing network
resource "azurerm_kubernetes_cluster" "tf-aks" {
  resource_group_name = azurerm_resource_group.tf-rg.name
  node_resource_group = "rg-${var.prefix}-node-resources"
  name                = "aks-${var.prefix}"
  kubernetes_version  = var.kubernetes_version
  location            = azurerm_resource_group.tf-rg.location
  dns_prefix          = "aks-${var.prefix}"

  default_node_pool{
    name                = "systempool"
    node_count          = var.system_node_count
    max_pods            = var.pods_per_node
    vm_size             = var.vm_size
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
    os_disk_size_gb     = var.os_disk_size
    os_disk_type        = "Managed"
    vnet_subnet_id      = azurerm_subnet.tf-ask-subnet.id
    
    node_labels = {
      "nodepool-type"    = "system"
      "environment"      = "poc"
      "nodepoolos"       = "linux"
      "app"              = "system-apps" 
  }
  }

  identity {
    type = "SystemAssigned"
  }

# RBAC and Azure AD Integration Block
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      azure_rbac_enabled = true
      admin_group_object_ids = [var.admin_aad_group_id]
    }
  }

  network_profile {
    dns_service_ip     = "10.41.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    load_balancer_sku  = "Standard"
    network_plugin     = "azure"
    network_policy     = "calico"
    outbound_type      = "loadBalancer"
    service_cidr       = "10.41.0.0/16"
  }

  depends_on = [azurerm_resource_group.tf-rg, azurerm_subnet.tf-ask-subnet]

  tags = var.tags

  }

  resource "azurerm_kubernetes_cluster_node_pool" "tf-aks-workerpool" {
    name                = "workerpool"
    kubernetes_cluster_id = azurerm_kubernetes_cluster.tf-aks.id
    node_count          = var.worker_node_count
    max_pods            = var.pods_per_node
    vm_size             = var.vm_size
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
    os_disk_size_gb     = var.os_disk_size
    os_disk_type        = "Managed"
    vnet_subnet_id      = azurerm_subnet.tf-ask-subnet.id
    

    depends_on = [azurerm_resource_group.tf-rg, azurerm_kubernetes_cluster.tf-aks]

  tags = var.tags  
}
