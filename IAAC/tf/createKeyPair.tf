variable "key_name" {
  type = string
  default = "DemoKey1"
}

resource "tls_private_key" "demo" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.demo.public_key_openssh}"
}

resource "aws_key_pair" "DemoApp" {
  key_name   = "${basename("${path.module}/../../../../AWS/Keys/DemoApp.pem")}"
  public_key = "${tls_private_key.demo.public_key_openssh}"
}

resource "aws_key_pair" "NewDemoApp" {
  key_name   = "NewDemoApp"
  public_key = "${file("${path.module}/../../../../AWS/Keys/NewDemoApp.pub")}"
}


/*
Create a Key Pair in AWS. Download the pem file
Execute ssh-keygen -f private.pem -y > public.pub
This generates the public key from the private key.

Add the corresponding resource section with key_name and public_key.
Execute terraform import aws_key_pair.NewDemoApp.key_name NewDemoApp

Execute terraform apply
Now this attribute is ready to be used.

This works
key_name   = "${basename("${path.module}/../../../../AWS/Keys/NewDemoApp")}"
*/
