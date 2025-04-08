resource "aws_s3_bucket" "cur_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "Kubecost CUR Bucket"
  }
}

resource "aws_s3_bucket_policy" "cur_policy" {
  bucket = aws_s3_bucket.cur_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSBillingPutObject",
        Effect    = "Allow",
        Principal = {
          Service = "billingreports.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.cur_bucket.arn}/*"
      },
      {
        Sid       = "AWSBillingGetBucketAcl",
        Effect    = "Allow",
        Principal = {
          Service = "billingreports.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cur_bucket.arn
      }
    ]
  })
}

resource "aws_cur_report_definition" "cur" {
  report_name                = var.report_name
  time_unit                  = "DAILY"
  format                     = "textORcsv"
  compression                = "GZIP"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cur_bucket.bucket
  s3_region                  = var.region
  s3_prefix                  = var.prefix
  report_versioning          = "OVERWRITE_REPORT"
}
