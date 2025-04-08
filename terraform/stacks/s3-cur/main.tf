module "s3-cur" {
  source      = "../../modules/s3-cur"
  bucket_name = "finops-cost-reports"
  report_name = "kubecost-report"
  prefix      = "kubecost-report"
  region      = "ap-northeast-2"
}
