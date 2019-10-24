resource "aws_launch_configuration" "demoLaunchConfig" {
  name   = "demoLaunchConfig"
  image_id      = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.demoInstanceProfile.name}"
  key_name      = "${aws_key_pair.NewDemoApp.key_name}"
  security_groups = ["${aws_security_group.allow_http_ssh.name}"]
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

  lifecycle {
    create_before_destroy = true
  }
}
