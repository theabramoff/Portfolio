variable "dbname" {
  type = string
}



resource "aws_instance" "myec2db" {
  ami = "ami-05760f62e0b3eab56"
  instance_type = "t2.micro"

   tags = {
      Name = var.dbname
  }
}




 