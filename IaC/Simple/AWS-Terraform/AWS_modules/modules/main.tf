provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "myec2" {
  ami = "ami-05760f62e0b3eab56"
  instance_type = "t2.micro"

  tags = {
      Name = "Web Server"
  }
}

module "dbserver" {
  source = "./db"
}