variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "location" {
  type = string
}

variable "location_code" {
  type = string
}

variable "environment" {
  type = string
}

variable "redundancy" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}
