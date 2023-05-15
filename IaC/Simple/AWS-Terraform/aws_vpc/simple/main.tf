provider "aws" {
  region    = "eu-north-1"

}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

output "vpcip" {
  value = aws_vpc.myvpc.id
}