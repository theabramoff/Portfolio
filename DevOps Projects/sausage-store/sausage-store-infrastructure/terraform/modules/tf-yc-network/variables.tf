#---------------------------------------
# Network variables
#---------------------------------------
locals {
 network_zones = toset(["ru-central1-a", "ru-central1-b", "ru-central1-c"])
}
 
/*
variable "network_zone" {
  description = "Yandex.Cloud network availability zones"
  type        = string
  default     = "ru-central1-a"
}
*/

