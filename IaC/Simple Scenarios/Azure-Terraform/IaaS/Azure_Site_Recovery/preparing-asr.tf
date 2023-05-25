#####Fabric#####
#deploy primary fabric
resource "azurerm_site_recovery_fabric" "tf-primary" {
  name                = "primary-fabric"
  resource_group_name = azurerm_resource_group.tf-rg-ne-asr.name
  recovery_vault_name = azurerm_recovery_services_vault.tf-vault.name
  location            = var.location-we

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_recovery_services_vault.tf-vault
  ]
}
#deploy secondary fabric
resource "azurerm_site_recovery_fabric" "tf-secondary" {
  name                = "secondary-fabric"
  resource_group_name = azurerm_resource_group.tf-rg-ne-asr.name
  recovery_vault_name = azurerm_recovery_services_vault.tf-vault.name
  location            = var.location-ne
        
depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_recovery_services_vault.tf-vault
  ]
}
#deploy primary container
resource "azurerm_site_recovery_protection_container" "tf-primary-container" {
  name                 = "primary-protection-container"
  resource_group_name  = azurerm_resource_group.tf-rg-ne-asr.name
  recovery_vault_name  = azurerm_recovery_services_vault.tf-vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.tf-primary.name

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_recovery_services_vault.tf-vault
  ]
}
#deploy secondary container
resource "azurerm_site_recovery_protection_container" "tf-secondary-container" {
  name                 = "secondary-protection-container"
  resource_group_name  = azurerm_resource_group.tf-rg-ne-asr.name
  recovery_vault_name  = azurerm_recovery_services_vault.tf-vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.tf-secondary.name

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_recovery_services_vault.tf-vault
  ]
}

#####mapping########
#container mapping
resource "azurerm_site_recovery_protection_container_mapping" "tf-container-mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = azurerm_resource_group.tf-rg-ne-asr.name
  recovery_vault_name                       = azurerm_recovery_services_vault.tf-vault.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.tf-primary.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.tf-primary-container.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.tf-secondary-container.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.tf-policy-1.id

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_recovery_services_vault.tf-vault
  ]
}
#network mapping
resource "azurerm_site_recovery_network_mapping" "tf-network-mapping" {
  name                        = "network-mapping"
  resource_group_name         = azurerm_resource_group.tf-rg-ne-asr.name
  recovery_vault_name         = azurerm_recovery_services_vault.tf-vault.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.tf-primary.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.tf-secondary.name
  source_network_id           = azurerm_virtual_network.tf-vnet-we.id
  target_network_id           = azurerm_virtual_network.tf-vnet-ne.id

depends_on=[
  azurerm_resource_group.tf-rg-ne-asr,
  azurerm_resource_group.tf-rg-we,
  azurerm_resource_group.tf-rg-ne,
  azurerm_recovery_services_vault.tf-vault,
  azurerm_virtual_network.tf-vnet-we,
  azurerm_virtual_network.tf-vnet-ne
  ]
}

####### building replica #####
# this pasrt is to perform ASR configuration - building replica
resource "azurerm_site_recovery_replicated_vm" "tf-vm-replication" {
  name                                      = "vm-replication"
  resource_group_name                       = azurerm_resource_group.tf-rg-ne-asr.name
  recovery_vault_name                       = azurerm_recovery_services_vault.tf-vault.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.tf-primary.name
  source_vm_id                              = azurerm_virtual_machine.tf-vm.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.tf-policy-1.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.tf-primary-container.name

  target_resource_group_id                = azurerm_resource_group.tf-rg-ne.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.tf-secondary.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.tf-secondary-container.id

  managed_disk {
    disk_id                    = azurerm_virtual_machine.tf-vm.storage_os_disk[0].managed_disk_id
    staging_storage_account_id = azurerm_storage_account.tf-sa-we.id
    target_resource_group_id   = azurerm_resource_group.tf-rg-ne.id
    target_disk_type           = "Standard_LRS"
    target_replica_disk_type   = "Standard_LRS"
  }

  managed_disk {
    disk_id                    = azurerm_managed_disk.tf-Disk-01.id
    staging_storage_account_id = azurerm_storage_account.tf-sa-we.id
    target_resource_group_id   = azurerm_resource_group.tf-rg-ne.id
    target_disk_type           = "Standard_LRS"
    target_replica_disk_type   = "Standard_LRS"
  }

  managed_disk {
    disk_id                    = azurerm_managed_disk.tf-Disk-02.id
    staging_storage_account_id = azurerm_storage_account.tf-sa-we.id
    target_resource_group_id   = azurerm_resource_group.tf-rg-ne.id
    target_disk_type           = "Standard_LRS"
    target_replica_disk_type   = "Standard_LRS"
  }

  network_interface {
    source_network_interface_id   = azurerm_network_interface.tf-nic.id
    target_subnet_name            = azurerm_subnet.tf-snet-ne.name
    recovery_public_ip_address_id = azurerm_public_ip.tf-pip-ne.id
  }

  depends_on = [
    azurerm_site_recovery_protection_container_mapping.tf-container-mapping,
    azurerm_site_recovery_network_mapping.tf-network-mapping,
    azurerm_resource_group.tf-rg-ne-asr,
    azurerm_resource_group.tf-rg-we,
    azurerm_resource_group.tf-rg-ne,
    azurerm_recovery_services_vault.tf-vault,
    azurerm_virtual_network.tf-vnet-we,
    azurerm_virtual_network.tf-vnet-ne,
    azurerm_virtual_machine.tf-vm
  ]
}