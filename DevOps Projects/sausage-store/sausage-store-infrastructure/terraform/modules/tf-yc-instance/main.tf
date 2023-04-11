locals {
  vm_name = format("%s-%s-%s", var.chapter, var.lesson, var.login)
}

#---------------------------------------
# Compute
#---------------------------------------
resource "yandex_compute_instance" "vm-1" {
  name        = local.vm_name
  description = "VM for Ansible"
  zone = "${var.network_zone}"

  resources {
    cores  = var.vm_cores
    memory = var.vm_ram
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.OS_drive
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
  }

  metadata = {
    user-data = "${file("~/.ssh/${var.meta_data}")}"
    serial-port-enable = "1"
  }
  scheduling_policy {
    preemptible = var.policy
  }
}

