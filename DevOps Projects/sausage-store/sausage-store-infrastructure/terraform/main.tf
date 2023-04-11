module "yandex_cloud_vpc" {
  source = "./modules/tf-yc-network"
}
/*
output "yandex_cloud_outputs" {
  value = module.yandex_cloud_vpc
}
*/

#Ansible VM deployment - Master
module "yandex_cloud_vm-01" {
  source = "./modules/tf-yc-instance"

  chapter    = "chapter5"
  lesson     = "lesson2"
  login      = "std-010-057"
  meta_data  = "meta.txt"
  subnet_id  = module.yandex_cloud_vpc.yandex_vpc_subnets["ru-central1-a"].subnet_id

}
output "yandex_cloud_vm-01_outputs" {
  value = module.yandex_cloud_vm-01
}
/*
#Ansible VM deployment - Slave
module "yandex_cloud_vm-02_for-ansible" {
  source = "./modules/tf-yc-instance"

  chapter    = "temp"
  lesson     = "01"
  login      = "std-010-057"
  meta_data  = "meta_v2.txt"
  subnet_id  = module.yandex_cloud_vpc.yandex_vpc_subnets["ru-central1-a"].subnet_id

}
output "yandex_cloud_vm-02_for-ansible_outputs" {
  value = module.yandex_cloud_vm-02_for-ansible
}
*/