/*resource "aws_codedeploy_app" "demoAppDeploy" {
  compute_platform = "Server"
  name             = "demoAppDeploy"
}*/

resource "aws_iam_role" "demoApp" {
  name = "deploy-role"

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
  role       = "${aws_iam_role.demoApp.name}"
}

resource "aws_codedeploy_app" "demoAppDeploy" {
  compute_platform = "Server"
  name = "demoAppDeploy"
}

resource "aws_sns_topic" "demoAppDeploy" {
  name = "deployTopic"
}

resource "aws_codedeploy_deployment_group" "demoAppDeploy" {
  app_name              = "${aws_codedeploy_app.demoAppDeploy.name}"
  deployment_group_name = "demoAppDeployGroup"
  service_role_arn      = "${aws_iam_role.demoApp.arn}"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "CodeDeployInstance"
    }
  }
    /*ec2_tag_filter {
      key   = "filterkey2"
      type  = "KEY_AND_VALUE"
      value = "filtervalue"
    }*/

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
