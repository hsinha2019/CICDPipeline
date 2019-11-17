resource "aws_lb_target_group" "demoTargetGroup" {
  name     = "demoTargetGroup"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_default_vpc.default.id}"
  health_check {
    enabled = "true"
    interval = "10"
    path = "/connect.php"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = "5"
    healthy_threshold = "5"
    unhealthy_threshold = "2"
    matcher = "200"
  }
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "demoTGAttachment" {
  target_group_arn = "${aws_lb_target_group.demoTargetGroup.arn}"
  target_id        = "${aws_instance.demoDeployInstanceForClassicLB.id}"
  port             = "80"
}
