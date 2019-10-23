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
  name = "demoAppDeploy"
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
  deployment_group_name = "demoAppDeployGroup"
  service_role_arn      = "${aws_iam_role.codedeploy_role.arn}"

  /*deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    elb_info {
      name = "classicLoadDemoBalancer"
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 60
    }

    green_fleet_provisioning_option {
      action = "DISCOVER_EXISTING"
    }

    terminate_blue_instances_on_deployment_success {
      action = "KEEP_ALIVE"
    }
  }*/

  deployment_config_name = "${aws_codedeploy_deployment_config.codeDeployConfig.id}"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "CodeDeployInstance"
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
