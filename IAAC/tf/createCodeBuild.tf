/*resource "aws_iam_role" "codebuild_role" {
  name = "demoBuildRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild_policy"
  role = "${aws_iam_role.codebuild_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Effect": "Allow",
    "Action": [
              "logs:*"
          ],
    "Resource": "*"
    },
    {
    "Effect": "Allow",
    "Action": [
              "s3:*"
          ],
    "Resource": "*"
    },
    {
    "Effect": "Allow",
    "Action": [
              "ec2:*"
          ],
    "Resource": "*"
    },
    {
    "Effect": "Allow",
    "Action": [
              "codecommit:*"
          ],
    "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_codebuild_project" "demoCodeBuild" {
  name          = "demoCodeBuild"
  description   = "demo_codebuild_project"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.example.bucket}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "SOME_KEY1"
      value = "SOME_VALUE1"
    }

    environment_variable {
      name  = "SOME_KEY2"
      value = "SOME_VALUE2"
      type  = "PARAMETER_STORE"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status = "ENABLED"
      location = "${aws_s3_bucket.example.id}/build-log"
    }
  }

  source {
    type       = "CODECOMMIT"
    location   = "${aws_codecommit_repository.FirstApplication.repository_name}"
    #branch = "master"
    #git_clone_depth = 1
  }

  vpc_config {
    vpc_id = "${aws_vpc.example.id}"

    subnets = [
      "${aws_subnet.example1.id}",
      "${aws_subnet.example2.id}",
    ]

    security_group_ids = [
      "${aws_security_group.example1.id}",
      "${aws_security_gorup.example2.id}",
    ]
  }

  tags = {
    Environment = "Test"
  }
}*/
