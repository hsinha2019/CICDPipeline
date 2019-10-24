provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_iam_role" "ec2_role" {
  name = "demoEc2Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeCommitFullAccess1" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
  role       = "${aws_iam_role.ec2_role.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = "${aws_iam_role.ec2_role.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${aws_iam_role.ec2_role.name}"
}

resource "aws_iam_instance_profile" "demoInstanceProfile" {
  name = "demoInstanceProfile"
  role = "${aws_iam_role.ec2_role.name}"
}

resource "aws_instance" "demoDeployInstance" {
  ami           = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.NewDemoApp.key_name}"
  security_groups = ["${aws_security_group.allow_http_ssh.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.demoInstanceProfile.name}"
  count = 3

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum -y install ruby
              sudo yum -y install wget
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
              chmod +x ./install
              sudo ./install auto
              sudo service codedeploy-agent status
              EOF
    tags = {
      Name = "InPlaceDeploy"
    }
}

resource "aws_instance" "demoDeployInstanceForClassicLB" {
  ami           = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.NewDemoApp.key_name}"
  security_groups = ["${aws_security_group.allow_http_ssh.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.demoInstanceProfile.name}"


  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum -y install ruby
              sudo yum -y install wget
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
              chmod +x ./install
              sudo ./install auto
              sudo service codedeploy-agent status
              EOF
    tags = {
      Name = "BlueGreenDeploy"
    }
}
