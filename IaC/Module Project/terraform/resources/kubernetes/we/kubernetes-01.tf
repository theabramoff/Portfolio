#---------------------------------------
# Kubernetes
#---------------------------------------
module "kubernetes-01" {
  source = "../../../modules/kubernetes"
  
    subscription_code       = var.subscription_code
    resource_group_name     = var.resource_group_name
    location                = var.location
    location_code           = var.location_code
    # cluster type
    # private                 = "true"  #default false
    project_name            = "test-k8s"
    environment             = "poc"
    # vnet for AKS
    vnet_segment            = "< ... >"
    subnet                  = "< ... >"
    # network config, replace with < ... >
    service_cidr            = "< ... >"
    dns_ip                  = "< ... >"
    # API authorized IP (if cluster is public), replace with < ... >
    # api_authorized_ip       = ["< ... >","< ... >"]
    # DNS for vNet , replace with < ... >
    dns                     = ["< ... >"]
    # sizes for VMSS nodes
    vm_size_system          = "Standard_D2s_v3"
    vm_size_worker          = "Standard_D2s_v3"

  # route table, replace with < ... >
  routes = [
      { name = "default_route", address_prefix = "< ... >", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "< ... >" },
      { name = "route_1", address_prefix = "< ... >", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "< ... >" }
    ] 
#---------------------------------------
# Tagging
#---------------------------------------
    project_tags = {
        Region:"USA",
        OwnedBy:"Abramov, Andrey",
        OwnerBackupPerson:"N/A",
        ITOwnerGroup:"N/A",
        Description:"Kubernetes for test",
        LifecycleEnd:"31DEC2023"
    }
}