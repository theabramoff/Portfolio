#
#
#https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic#restrict-egress-traffic-using-azure-firewall
#
#
#resource group for the environment
resource "azurerm_resource_group" "tf-rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Description       = "Evaluation of containers and Kubernetes security features in Azure"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31June2023"
  }
}

#Create a virtual network with multiple subnets
resource "azurerm_virtual_network" "tf-vnet" {
  name                = var.vnet
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = ["10.42.0.0/16"]

  tags = {
    Description       = "Evaluation of containers and Kubernetes security features in Azure"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31June2023"
  }
}

resource "azurerm_subnet" "tf-ask-subnet" {
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  name                 = var.snetask
  address_prefixes     = ["10.42.1.0/24"]
}

resource "azurerm_subnet" "tf-afw-subnet" {
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  name                 = var.snetfw
  address_prefixes     = ["10.42.2.0/24"]
}

resource "azurerm_public_ip" "tf-afw-pip" {
  name                = var.pipafw
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Description       = "Evaluation of containers and Kubernetes security features in Azure"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31June2023"
  }
}

# Azure Firewall - Create and set up an Azure Firewall with a UDR
resource "azurerm_firewall" "tf-afw" {
  name                = var.afw
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  # https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16
  dns_servers = ["168.63.129.16"] # - workaround. dns proxy is not supported by TF

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.tf-afw-subnet.id
    #private_ip_address   = "10.42.2.4" # figure out how to link it to an object
    public_ip_address_id = azurerm_public_ip.tf-afw-pip.id
  }

  tags = {
    Description       = "Evaluation of containers and Kubernetes security features in Azure"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31June2023"
  }
}

# Adding firewall rules
resource "azurerm_firewall_network_rule_collection" "tf-afw-network-rule" {
  name                = "aksfwnr"
  azure_firewall_name = azurerm_firewall.tf-afw.name
  resource_group_name = azurerm_resource_group.tf-rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "apiudp"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "1194",
    ]

    destination_addresses = [
      "AzureCloud.WestEurope",
    ]

    protocols = [
      "UDP",
    ]
  }

  rule {
    name = "apitcp"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "900",
    ]

    destination_addresses = [
      "AzureCloud.WestEurope",
    ]

    protocols = [
      "TCP",
    ]
  }

  rule {
    name = "time"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "123",
    ]

    destination_fqdns = [
      "AzureCloud.WestEurope",
    ]

    protocols = [
      "UDP",
    ]
  }
}

resource "azurerm_firewall_application_rule_collection" "tf-afw-app-rule" {
  name                = "aksfwar"
  azure_firewall_name = azurerm_firewall.tf-afw.name
  resource_group_name = azurerm_resource_group.tf-rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "fqdn-tag"

    source_addresses = [
      "*",
    ]

    fqdn_tags = [
      "AzureKubernetesService",
    ]
  }
rule {
    name = "fqdn-target"

    source_addresses = [
      "*",
    ]

    target_fqdns = [
      "*.microsoft.com",
    ]

    protocol {
      port = "80"
      type = "Http"
    }
     protocol {
      port = "443"
      type = "Https"
    } 
  }
}


# Azure RT - Create a UDR with a hop to Azure Firewall & Associate the route table to AKS

resource "azurerm_route_table" "tf-rt" {
  name                          = var.rt
  location                      = var.location
  resource_group_name           = azurerm_resource_group.tf-rg.name
  disable_bgp_route_propagation = true

  tags = {
    Description       = "Evaluation of containers and Kubernetes security features in Azure"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31June2023"
  }
}

resource "azurerm_route" "tf-route-engress" {
  resource_group_name    = var.resource_group_name
  name                   = "fwrn-${var.prefix}"
  route_table_name       = azurerm_route_table.tf-rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.42.2.4"

  depends_on = [
    azurerm_subnet.tf-afw-subnet
  ]
}

resource "azurerm_route" "tf-route-internet" {
  name                = "fwrn-${var.prefix}-internet"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.tf-rt.name
  address_prefix      = "20.82.69.27/32" # figure out how to link it azurerm_public_ip.tf-afw-pip.ip_address
  next_hop_type       = "Internet"

  depends_on = [
    azurerm_public_ip.tf-afw-pip
  ]
}

resource "azurerm_subnet_route_table_association" "tf-rt-association" {
  subnet_id      = azurerm_subnet.tf-ask-subnet.id
  route_table_id = azurerm_route_table.tf-rt.id

  depends_on = [
    azurerm_route_table.tf-rt
  ]
}


#Deploy AKS with outbound type of UDR to the existing network
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
    max_pods            = var.pods_per_node
    vm_size             = var.vm_size
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
    os_disk_size_gb     = var.os_disk_size
    os_disk_type        = "Managed"
    vnet_subnet_id      = azurerm_subnet.tf-ask-subnet.id
  }

  identity {
    type = "SystemAssigned"
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
  depends_on = [
    azurerm_resource_group.tf-rg, azurerm_subnet.tf-ask-subnet
  ]
  tags = {
    Description       = "Evaluation of containers and Kubernetes security features in Azure"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
    LifecycleEnd      = "31June2023"
  }
}