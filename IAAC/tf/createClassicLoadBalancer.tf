resource "aws_elb" "demoClassicLoadBal" {
  name               = "demoElb"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c","us-east-1d", "us-east-1e", "us-east-1f"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/connect.php"
    interval            = 30
  }
  security_groups             = ["${aws_security_group.allow_http_ssh.id}"]
  instances                   = ["${aws_instance.demoDeployInstanceForClassicLB.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 30
  connection_draining         = true
  connection_draining_timeout = 30

  tags = {
    Name = "demoClassicLoadBal"
  }
}
