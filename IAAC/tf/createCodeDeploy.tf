resource "aws_iam_role" "codedeploy_role" {
  name = "demoDeployRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.codedeploy_role.name}"
}

resource "aws_iam_role_policy_attachment" "AWSCodeCommitFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
  role       = "${aws_iam_role.codedeploy_role.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${aws_iam_role.codedeploy_role.name}"
}

resource "aws_codedeploy_app" "demoAppDeploy" {
  compute_platform = "Server"
  name = "PHPApp"
}

resource "aws_sns_topic" "demoAppDeploy" {
  name = "deployTopic"
}

resource "aws_codedeploy_deployment_config" "codeDeployConfig" {
  deployment_config_name = "demoDeploymentConfig"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 1
  }
}



resource "aws_codedeploy_deployment_group" "demoAppDeploy" {
  app_name              = "${aws_codedeploy_app.demoAppDeploy.name}"
  deployment_group_name = "InPlaceAppDG"
  service_role_arn      = "${aws_iam_role.codedeploy_role.arn}"


  deployment_config_name = "${aws_codedeploy_deployment_config.codeDeployConfig.id}"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "InPlaceDeploy"
    }
  }

    trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "deployAppTrigger"
    trigger_target_arn = "${aws_sns_topic.demoAppDeploy.arn}"
    }

    auto_rollback_configuration {
      enabled = true
      events  = ["DEPLOYMENT_FAILURE"]
    }
  }


  resource "aws_codedeploy_deployment_group" "demoBlueGreenAppDeploy" {
    app_name              = "${aws_codedeploy_app.demoAppDeploy.name}"
    deployment_group_name = "BlueGreenAppDG"
    service_role_arn      = "${aws_iam_role.codedeploy_role.arn}"
    autoscaling_groups    = ["${aws_autoscaling_group.demoAppASG.name}"]

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type   = "BLUE_GREEN"
    }

    /*load_balancer_info {
      elb_info {
        name = "${aws_elb.demoClassicLoadBal.name}"
      }
    }*/

    load_balancer_info {
      /*
      This is required for Classic Load balancers
      elb_info {
        name = "${aws_lb.demoAppLB.name}"
      }*/
      target_group_info {
        name = "${aws_lb_target_group.demoTargetGroup.name}"
      }
    }

    blue_green_deployment_config {
      deployment_ready_option {
        action_on_timeout    = "CONTINUE_DEPLOYMENT"
        #wait_time_in_minutes = 5
      }

      green_fleet_provisioning_option {
        action = "COPY_AUTO_SCALING_GROUP"
      }

      terminate_blue_instances_on_deployment_success {
        action = "TERMINATE"
        termination_wait_time_in_minutes = "5"
      }
    }

    deployment_config_name = "CodeDeployDefault.AllAtOnce"

    ec2_tag_set {
      ec2_tag_filter {
        key   = "Name"
        type  = "KEY_AND_VALUE"
        value = "BlueGreenDeploy"
      }
    }

      trigger_configuration {
      trigger_events     = ["DeploymentFailure"]
      trigger_name       = "deployAppTrigger"
      trigger_target_arn = "${aws_sns_topic.demoAppDeploy.arn}"
      }

      auto_rollback_configuration {
        enabled = true
        events  = ["DEPLOYMENT_FAILURE"]
      }
    }
