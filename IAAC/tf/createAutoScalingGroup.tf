resource "aws_autoscaling_group" "demoASG" {
  name                 = "demoAutoScaling"
  launch_configuration = "${aws_launch_configuration.demoLaunchConfig.name}"
  min_size             = 1
  max_size             = 3

  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c","us-east-1d", "us-east-1e", "us-east-1f"]
  default_cooldown     = 5
  health_check_grace_period  = 10
  health_check_type    = "EC2"
  desired_capacity     = 2
  load_balancers       = ["${aws_elb.demoClassicLoadBal.name}"]
  tags = [
          {
          "key"="Name"
          "value"="BlueGreenDeploy"
          "propagate_at_launch"="true"}]
  lifecycle {
    create_before_destroy = true
  }
}
