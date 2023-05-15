provider "aws" {
  region    = "eu-north-1"

}

variable "vpcname" {
  type = string
  default = "terraformvpc"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

tags = {
    name = var.vpcname
    }
}