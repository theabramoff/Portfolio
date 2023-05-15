
#resource group to be created
resource "azurerm_resource_group" "tf-rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Description       = "Test ASK deployment"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
  }
}

resource "azurerm_virtual_network" "tf-vnet" {
  name                = var.vnet
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "tf-subnet" {
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  name                 = "subnet"
  address_prefixes     = ["10.240.0.0/24"]
}

resource "azurerm_kubernetes_cluster" "tf-aks" {
  resource_group_name = azurerm_resource_group.tf-rg.name
  node_resource_group = "${var.resource_group_name}-node-resources"
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = azurerm_resource_group.tf-rg.location
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "agentpool"
    node_count          = var.system_node_count
    vm_size             = var.vm_size
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
    os_disk_size_gb     = var.os_disk_size
    os_disk_type        = "Managed"
    vnet_subnet_id      = azurerm_subnet.tf-subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    load_balancer_sku  = "Standard"
    network_plugin     = "azure"
    network_policy     = "calico"
    outbound_type      = "loadBalancer"
    service_cidr       = "10.0.0.0/16"

  }
  depends_on = [
    azurerm_resource_group.tf-rg, azurerm_subnet.tf-subnet
  ]
}
/*
resource "azurerm_container_registry" "tf-arc" {
  name                = var.arc_name
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  sku                 = "Standard"
  admin_enabled       = false

  depends_on = [
    azurerm_kubernetes_cluster.tf-aks
  ]
}

resource "azurerm_role_assignment" "tf-role_arcpull" {
  scope                            = azurerm_container_registry.tf-arc.id
  role_definition_name             = "ArcPull"
  principal_id                     = azurerm_kubernetes_cluster.tf-aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_container_registry.tf-arc
  ]

}
*/
