resource "aws_s3_bucket" "demo" {
  bucket = "democodepipeline2019forp15"
  acl    = "public-read-write"
  force_destroy = "true"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }

  versioning {
    enabled = true
  }
}
