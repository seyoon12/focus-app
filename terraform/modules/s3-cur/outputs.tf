output "s3_bucket_name" {
  value = aws_s3_bucket.cur_bucket.bucket
}

output "report_prefix" {
  value = var.prefix
}
