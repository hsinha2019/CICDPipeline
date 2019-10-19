provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

data "local_file" "pem"{
  filename = "/Users/Hershey/AWS/Keys/DemoApp.pem"
}

resource "local_file" "pem"{
  content = "${data.local_file.pem.content}"
  filename = "/Users/Hershey/AWS/Keys/DemoApp.pem"
}

resource "aws_instance" "demoDeployInstance" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  ##key_name      = "${local_file.pem.filename}"
  ##key_name      = file("$/Users/Hershey/AWS/Keys/DemoApp.pem")

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update
              sudo yum install ruby
              sudo yum install wget
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
              chmod +x ./install
              sudo ./install auto
              sudo service codedeploy-agent status
              EOF
    tags = {
      Name = "CodeDeployInstance"
    }
}
