#---------------------------------------
# Network
#---------------------------------------

data "yandex_vpc_network" "default" {
  name = "default"
}

data "yandex_vpc_subnet" "default" {
  for_each = local.network_zones
  name = "${data.yandex_vpc_network.default.name}-${each.key}"
}
