provider "aws" {
  secret_key = ""
  access_key = ""
  region     = "us-west-1"
}

resource "aws_instance" "K8-M" {
  ami           = ""
  instance_type = "t2.medium"
  key_name      = ""
  tags = { Name = "Kmaster" }
}

resource "aws_instance" "K8-S1" {
  ami           = ""
  instance_type = "t2.medium"
  key_name      = ""
  tags = { Name = "Kslave1" }
}

resource "aws_instance" "K8-S2" {
  ami           = ""
  instance_type = "t2.medium"
  key_name      = ""
  tags = { Name = "Kslave2" }
}
