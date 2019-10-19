resource "aws_s3_bucket" "Dev" {
  bucket = "my-tf-test-bucket1"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }

  versioning {
    enabled = true
  }
}
