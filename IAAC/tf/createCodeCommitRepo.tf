resource "aws_codecommit_repository" "FirstApplication" {
  repository_name = "mytestrepository"
  description     = "This is the Sample App Repository"
}

#data "aws_codecommit_repository" "mytestrepository" {
#  clone_url_ssh  = git-codecommit.us-west-1.amazonaws.com/v1/repos/MyDemoRepo
#}
