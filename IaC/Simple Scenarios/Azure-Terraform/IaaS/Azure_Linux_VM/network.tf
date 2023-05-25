

resource "azurerm_virtual_network" "tf-vnet" {
  name                = "vnet-${var.prefix}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
}

resource "azurerm_subnet" "tf-snet" {
  name                 = var.snet
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "tf-nsg" {
 
  name                = "nsg-${var.prefix}"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  
  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

   depends_on=[azurerm_resource_group.tf-rg]
}


# Associate the linux NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "tf-nsg-association" {
  
  subnet_id                 = azurerm_subnet.tf-snet.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id

depends_on=[azurerm_subnet.tf-snet]
}
# Get a Static Public IP
resource "azurerm_public_ip" "tf-pip" {
  
  name                = "pip-${var.prefix}"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  allocation_method   = "Static"

  depends_on=[azurerm_resource_group.tf-rg]
}