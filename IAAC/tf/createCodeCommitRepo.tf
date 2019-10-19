resource "aws_codecommit_repository" "FirstApplication" {
  repository_name = "MyTestRepository"
  description     = "This is the Sample App Repository"
}

#data "aws_codecommit_repository" "MyTestRepository" {
#  clone_url_ssh  = git-codecommit.us-west-1.amazonaws.com/v1/repos/MyDemoRepo
#}
