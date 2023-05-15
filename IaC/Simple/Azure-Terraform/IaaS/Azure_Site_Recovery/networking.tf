#########vnet we######

resource "azurerm_virtual_network" "tf-vnet-we" {
  name                = "vnet-${var.prefix-we}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.tf-rg-we.location
  resource_group_name = azurerm_resource_group.tf-rg-we.name

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne
  ]
}

resource "azurerm_subnet" "tf-snet-we" {
  name                 = "snet"
  resource_group_name  = azurerm_resource_group.tf-rg-we.name
  virtual_network_name = azurerm_virtual_network.tf-vnet-we.name
  address_prefixes     = ["10.1.1.0/24"]

depends_on=[
  azurerm_virtual_network.tf-vnet-we
  ]
}

resource "azurerm_network_security_group" "tf-nsg-we" {
 
  name                = "nsg-${var.prefix-we}"
  location            = azurerm_resource_group.tf-rg-we.location
  resource_group_name = azurerm_resource_group.tf-rg-we.name
  
  security_rule {
    name                       = "AllowRDP"
    description                = "Allow RDP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Storage-account-access"
    description                = "Allow outbound for storage accounts"
    priority                   = 150
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Storage.WestEurope"
  }

  security_rule {
    name                       = "Allow-Azure-Active-Directory"
    description                = "Allow outbound to Azure Active Directory"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureActiveDirectory"
  }

  security_rule {
    name                       = "Allow-Event-Hub"
    description                = "Allow outbound to Event Hub SR monitoring"
    priority                   = 250
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "EventHub.NorthEurope"
  }

  security_rule {
    name                       = "Allow-Azure-Site-Recovery"
    description                = "Allow outbound to Azure Site Recovery"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureSiteRecovery"
  }

depends_on=[
  azurerm_subnet.tf-snet-we
  ]
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "tf-nsg-association-we" {
  
  subnet_id                 = azurerm_subnet.tf-snet-we.id
  network_security_group_id = azurerm_network_security_group.tf-nsg-we.id

depends_on=[
azurerm_subnet.tf-snet-we
]

}
# Get a Static Public IP
resource "azurerm_public_ip" "tf-pip-we" {
  
  name                = "pip-${var.prefix-resource-we}"
  location            = azurerm_resource_group.tf-rg-we.location
  resource_group_name = azurerm_resource_group.tf-rg-we.name
  allocation_method   = "Static"

  depends_on=[
  azurerm_resource_group.tf-rg-we
  ]
}

#########vnet ne######

resource "azurerm_virtual_network" "tf-vnet-ne" {
  name                = "vnet-${var.prefix-ne}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.tf-rg-ne.location
  resource_group_name = azurerm_resource_group.tf-rg-ne.name

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne
  ]
}

resource "azurerm_subnet" "tf-snet-ne" {
  name                 = "snet"
  resource_group_name  = azurerm_resource_group.tf-rg-ne.name
  virtual_network_name = azurerm_virtual_network.tf-vnet-ne.name
  address_prefixes     = ["10.1.1.0/24"]

depends_on=[
  azurerm_virtual_network.tf-vnet-ne
  ]
}

resource "azurerm_network_security_group" "tf-nsg-ne" {
 
  name                = "nsg-${var.prefix-ne}"
  location            = azurerm_resource_group.tf-rg-ne.location
  resource_group_name = azurerm_resource_group.tf-rg-ne.name
  
  security_rule {
    name                       = "AllowRDP"
    description                = "Allow RDP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Storage-account-access"
    description                = "Allow outbound for storage accounts"
    priority                   = 150
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Storage.NorthEurope"
  }

  security_rule {
    name                       = "Allow-Azure-Active-Directory"
    description                = "Allow outbound to Azure Active Directory"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureActiveDirectory"
  }

  security_rule {
    name                       = "Allow-Event-Hub"
    description                = "Allow outbound to Event Hub SR monitoring"
    priority                   = 250
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "EventHub.WestEurope"
  }

  security_rule {
    name                       = "Allow-Azure-Site-Recovery"
    description                = "Allow outbound to Azure Site Recovery"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureSiteRecovery"
  }

depends_on=[
  azurerm_subnet.tf-snet-ne
  ]
}

# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "tf-nsg-association-ne" {
  
  subnet_id                 = azurerm_subnet.tf-snet-ne.id
  network_security_group_id = azurerm_network_security_group.tf-nsg-ne.id

depends_on=[
  azurerm_subnet.tf-snet-ne
  ]
}
# Get a Static Public IP
resource "azurerm_public_ip" "tf-pip-ne" {
  
  name                = "pip-${var.prefix-resource-ne}"
  location            = azurerm_resource_group.tf-rg-ne.location
  resource_group_name = azurerm_resource_group.tf-rg-ne.name
  allocation_method   = "Static"

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne
  ]
}

#######VM##########

resource "azurerm_network_interface" "tf-nic" {
  name                = "vm-${var.prefix-resource-we}"
  location            = azurerm_resource_group.tf-rg-we.location
  resource_group_name = azurerm_resource_group.tf-rg-we.name

  ip_configuration {
    name                          = "vmconfig"
    subnet_id                     = azurerm_subnet.tf-snet-we.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf-pip-we.id
  }

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  ]  
}