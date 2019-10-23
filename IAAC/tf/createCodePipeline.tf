resource "aws_iam_role" "codepipeline_role" {
  name = "demoPipelineRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Effect": "Allow",
    "Action": [
              "codecommit:*"
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
              "codedeploy:*"
          ],
    "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
  name     = "demoPipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.demo.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["NO_ARTIFACTS"]

      configuration = {
        RepositoryName   = "${aws_codecommit_repository.FirstApplication.repository_name}"
        BranchName = "master"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["NO_ARTIFACTS"]
      version         = "1"

      configuration = {
        ApplicationName = "${aws_codedeploy_app.demoAppDeploy.name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.demoAppDeploy.deployment_group_name}"
      }
    }
  }
}
