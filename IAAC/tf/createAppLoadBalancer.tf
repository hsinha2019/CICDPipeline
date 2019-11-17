resource "aws_lb" "demoAppLB" {
  name               = "demoAppLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_http_ssh.id}"]
  subnets            = ["${aws_default_subnet.us-east-1a.id}",
                        "${aws_default_subnet.us-east-1b.id}",
                        "${aws_default_subnet.us-east-1c.id}",
                        "${aws_default_subnet.us-east-1d.id}",
                        "${aws_default_subnet.us-east-1e.id}",
                        "${aws_default_subnet.us-east-1f.id}"]

  enable_deletion_protection = "false"

  tags = {
    Name = "demoAppLB"
  }
}

resource "aws_lb_listener" "forward" {
  load_balancer_arn = "${aws_lb.demoAppLB.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.demoTargetGroup.arn}"
  }
}
