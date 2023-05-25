# Create virtual network
resource "azurerm_virtual_network" "tf-network" {
    name                = "vnet-az01-srv-01"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.tf-rg.name

}

# Create subnet
resource "azurerm_subnet" "tf-subnet" {
    name                 = "subnet"
    resource_group_name  = azurerm_resource_group.tf-rg.name
    virtual_network_name = azurerm_virtual_network.tf-network.name
    address_prefixes       = ["10.0.1.0/24"]
    
}

# Create public IPs
resource "azurerm_public_ip" "tf-pip" {
    name                         = "pip-az01-srv-01"
    location                     = "westeurope"
    resource_group_name          = azurerm_resource_group.tf-rg.name
    allocation_method            = "Static"
    domain_name_label            = "az01-srv-01"
    #sku                          = "Standard"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "tf-nsg" {
    name                = "nsg-az01-srv-01"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.tf-rg.name

    security_rule {
        name                       = "RDP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}
# Connect the security group to the subnet
resource "azurerm_subnet_network_security_group_association" "TFnsgAssos" {
  subnet_id                 = azurerm_subnet.tf-subnet.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}

resource "azurerm_network_interface" "tf-nic" {
    name                      = "nic-az01-srv-01"
    location                  = "westeurope"
    resource_group_name       = azurerm_resource_group.tf-rg.name
    enable_accelerated_networking = "true"

    ip_configuration {
        name                          = "NicConfiguration01"
        subnet_id                     = azurerm_subnet.tf-subnet.id
        private_ip_address_allocation = "static"
        public_ip_address_id          = azurerm_public_ip.tf-pip.id   
    }
}

# Connect the security group to the network interface
#resource "azurerm_network_interface_security_group_association" "tfnsgassociation" {
  #  network_interface_id      = azurerm_network_interface.tfnicnew.id
  #  network_security_group_id = azurerm_network_security_group.tfnsg.id
#}