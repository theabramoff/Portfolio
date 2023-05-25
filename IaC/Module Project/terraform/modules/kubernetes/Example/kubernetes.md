
locals {

}

module "kubernetes-01" {
  source = "../../../../modules/kubernetes"
  

    subscription_code       = var.subscription_code
    resource_group_name     = var.resource_group_name
    resource_group_location = var.location
    location                = var.location
    location_code           = var.location_code
    #cluster type
    private                 = "true"  #default false
    project_name            = "test-k8s"
    environment             = "poc"
    #vnet for AKS
    vnet_segment            = "10.10.10.0/24"
    subnet                  = "10.10.10.0/24"
    #network config
    service_cidr            = "10.10.10.128/25"
    dns_ip                  = "10.10.10.132"
    #below are default
    #worker_node_count       =        #default 2
    #pods_per_node           =        #default 30
    #vm_size                 =        #default B2s
    #os_disk_size            =        #default 30 Gb
    #autoscaling             = "true"

    #tagging
    project_tags = {
        "Region":"USA",
        OwnedBy:"Abramov, Andrey",
        OwnerBackupPerson:"N/A",
        ITOwnerGroup:"N/A",

        "Description":"Kubernetes for test",
        "Lifecycle End":"31DEC2023"
    }
}
