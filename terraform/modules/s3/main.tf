resource "aws_s3_bucket" "codepipeline_s3" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name = "codepipeline-s3"
  }
}